# frozen_string_literal: true

RSpec.describe 'bit_field/type' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, [:name, :size, :type])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :initial_value, :reference, :type])
    RgGen.enable(:bit_field, :type, [:foo, :bar, :baz])
  end

  describe 'register_map' do
    def create_bit_fields(&block)
      create_register_map { register_block(&block) }.bit_fields
    end

    describe 'ビットフィールド型' do
      before(:all) do
        RgGen.define_list_item_feature(:bit_field, :type, [:foo, :bar, :qux]) do
          register_map {}
        end
      end

      after(:all) do
        delete_register_map_factory
        RgGen.delete(:bit_field, :type, [:foo, :bar, :qux])
      end

      specify '指定した型を #type で取得できる' do
        [
          [:foo, :bar],
          [:FOO, :BAR],
          ['foo', 'bar'],
          [random_string(/foo/i), random_string(/bar/i)],
          [' foo', ' bar'],
          ['foo ', 'bar ']
        ].each do |foo_type, bar_type|
          bit_fields = create_bit_fields do
            register do
              name 'foo_bar'
              bit_field { name 'foo'; bit_assignment lsb: 0; type foo_type }
              bit_field { name 'bar'; bit_assignment lsb: 1; type bar_type }
            end
          end
          expect(bit_fields[0]).to have_property(:type, :foo)
          expect(bit_fields[1]).to have_property(:type, :bar)
        end
      end

      context '型が指定されなかった場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0 }
              end
            end
          }.to raise_register_map_error 'no bit field type is given'

          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0; type nil }
              end
            end
          }.to raise_register_map_error 'no bit field type is given'

          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0; type '' }
              end
            end
          }.to raise_register_map_error 'no bit field type is given'
        end
      end

      context '有効になっていない型が指定された場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_bit_fields do
              register do
                name 'qux'
                bit_field { name 'qux'; bit_assignment lsb: 0; type :qux }
              end
            end
          }.to raise_register_map_error 'unknown bit field type: :qux'
        end
      end

      context '未定義の型が指定された場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_bit_fields do
              register do
                name 'baz'
                bit_field { name 'baz'; bit_assignment lsb: 0; type :buz }
              end
            end
          }.to raise_register_map_error 'unknown bit field type: :buz'
        end
      end
    end

    describe 'アクセス属性' do
      def create_bit_field(&block)
        RgGen.define_list_item_feature(:bit_field, :type, :foo) do
          register_map(&block)
        end
        bit_fields = create_bit_fields do
          register do
            name 'foo'
            bit_field { name 'foo'; bit_assignment lsb: 0; type :foo }
          end
        end
        bit_fields.first
      end

      after do
        delete_register_map_factory
        RgGen.delete(:bit_field, :type, :foo)
      end

      describe '.read_write' do
        it '読み書き属性を設定する' do
          bit_field = create_bit_field { read_write }
          expect(bit_field).to match_access(:read_write)
        end
      end

      describe '.read_olny' do
        it '読み取り専用属性を設定する' do
          bit_field = create_bit_field { read_only }
          expect(bit_field).to match_access(:read_only)
        end
      end

      describe '.write_only' do
        it '書き込み専用属性を設定する' do
          bit_field = create_bit_field { write_only }
          expect(bit_field).to match_access(:write_only)
        end
      end

      describe '.reserved' do
        it '予約済み属性を設定する' do
          bit_field = create_bit_field { reserved }
          expect(bit_field).to match_access(:reserved)
        end
      end

      specify '規定属性は読み書き属性' do
        bit_field = create_bit_field {}
        expect(bit_field).to match_access(:read_write)
      end
    end

    describe '揮発性' do
      context '.volatileが指定されている場合' do
        before do
          RgGen.define_list_item_feature(:bit_field, :type, :foo) do
            register_map { volatile }
          end
        end

        after do
          delete_register_map_factory
          RgGen.delete(:bit_field, :type, :foo)
        end

        specify 'ビットフィールドは揮発性' do
          bit_fields = create_bit_fields do
            register do
              name 'register_0'
              bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :foo }
            end
          end

          expect(bit_fields[0]).to have_property(:volatile?, true)
        end
      end

      context '.non_volatileが指定されている場合' do
        before do
          RgGen.define_list_item_feature(:bit_field, :type, :foo) do
            register_map { non_volatile }
          end
        end

        after do
          delete_register_map_factory
          RgGen.delete(:bit_field, :type, :foo)
        end

        specify 'ビットフィールドは不揮発性' do
          bit_fields = create_bit_fields do
            register do
              name 'register_0'
              bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :foo }
            end
          end

          expect(bit_fields[0]).to have_property(:volatile?, false)
        end
      end

      context '.volatile?にブロックが指定された場合' do
        before do
          RgGen.define_list_item_feature(:bit_field, :type, :foo) do
            register_map do
              volatile? { @volatile }
              build { @volatile = true }
            end
          end

          RgGen.define_list_item_feature(:bit_field, :type, :bar) do
            register_map do
              volatile? { @volatile }
              build { @volatile = false }
            end
          end
        end

        after do
          delete_register_map_factory
          RgGen.delete(:bit_field, :type, [:foo, :bar])
        end

        specify 'ブロックの評価結果がビットフィールドの揮発性' do
          bit_fields = create_bit_fields do
            register do
              name 'register_0'
              bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :foo }
              bit_field { name 'bit_field_1'; bit_assignment lsb: 1; type :bar }
            end
          end

          expect(bit_fields[0]).to have_property(:volatile?, true)
          expect(bit_fields[1]).to have_property(:volatile?, false)
        end
      end

      context '未指定の場合' do
        before do
          RgGen.define_list_item_feature(:bit_field, :type, :foo) do
            register_map {}
          end
        end

        after do
          delete_register_map_factory
          RgGen.delete(:bit_field, :type, :foo)
        end

        specify 'ビットフィールドは不揮発性' do
          bit_fields = create_bit_fields do
            register do
              name 'register_0'
              bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :foo }
            end
          end

          expect(bit_fields[0]).to have_property(:volatile?, true)
        end
      end
    end
  end

  describe 'sv ral' do
    include_context 'sv ral common'

    def create_bit_fields(&body)
      create_sv_ral(&body).bit_fields
    end

    describe '#access' do
      before(:all) do
        RgGen.define_list_item_feature(:bit_field, :type, :foo) do
          register_map {}
          sv_ral {}
        end
        RgGen.define_list_item_feature(:bit_field, :type, :bar) do
          register_map {}
          sv_ral { access :baz }
        end
      end

      after(:all) do
        delete_register_map_factory
        delete_sv_ral_factory
        RgGen.delete(:bit_field, :type, [:foo, :bar])
      end

      context 'アクセス権の指定がない場合' do
        it '大文字化した型名をアクセス権として返す' do
          bit_fields = create_bit_fields do
            register do
              name 'register_0'
              bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :foo }
            end
          end
          expect(bit_fields[0].access).to eq 'FOO'
        end
      end

      context '.accessでアクセス権の指定がある場合' do
        it '指定されたアクセス権を大文字化して返す' do
          bit_fields = create_bit_fields do
            register do
              name 'register_0'
              bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :bar }
            end
          end
          expect(bit_fields[0].access).to eq 'BAZ'
        end
      end
    end

    describe '#model_name' do
      before(:all) do
        RgGen.define_list_item_feature(:bit_field, :type, :foo) do
          register_map {}
          sv_ral {}
        end
        RgGen.define_list_item_feature(:bit_field, :type, :bar) do
          register_map {}
          sv_ral { model_name :rggen_bar_field }
        end
        RgGen.define_list_item_feature(:bit_field, :type, :baz) do
          register_map {}
          sv_ral { model_name { "rggen_ral_#{bit_field.name}" } }
        end
      end

      after(:all) do
        delete_register_map_factory
        delete_sv_ral_factory
        RgGen.delete(:bit_field, :type, [:foo, :bar, :baz])
      end

      context 'モデル名の指定がない場合' do
        it 'rggen_ral_fieldをモデル名として返す' do
          bit_fields = create_bit_fields do
            register do
              name 'register_0'
              bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :foo }
            end
          end
          expect(bit_fields[0].model_name).to eq :rggen_ral_field
        end
      end

      context '.model_nameでモデル名の指定がある場合' do
        it '指定されたモデル名を返す' do
          bit_fields = create_bit_fields do
            register do
              name 'register_0'
              bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :bar }
            end
          end
          expect(bit_fields[0].model_name).to eq :rggen_bar_field
        end
      end

      context '.model_nameにブロックが渡された場合' do
        it 'ブロックの実行結果をモデル名として返す' do
          bit_fields = create_bit_fields do
            register do
              name 'register_0'
              bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :baz }
            end
          end
          expect(bit_fields[0].model_name).to eq 'rggen_ral_bit_field_0'
        end
      end
    end

    describe '#ral_model' do
      before(:all) do
        RgGen.define_list_item_feature(:bit_field, :type, :foo) do
          register_map {}
          sv_ral {}
        end
        RgGen.define_list_item_feature(:bit_field, :type, :bar) do
          register_map {}
          sv_ral { model_name :rggen_bar_field }
        end
        RgGen.define_list_item_feature(:bit_field, :type, :baz) do
          register_map {}
          sv_ral { model_name { "rggen_ral_#{bit_field.name}" } }
        end
      end

      after(:all) do
        delete_register_map_factory
        delete_sv_ral_factory
        RgGen.delete(:bit_field, :type, [:foo, :bar, :baz])
      end

      it 'フィールドモデル変数#ral_model' do
        bit_fields = create_bit_fields do
          register do
            name 'register_0'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :foo }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 1, sequence_size: 4; type :foo }
          end
          register do
            name 'register_1'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :bar }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 1, sequence_size: 4; type :bar }
          end
          register do
            name 'register_2'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :baz }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 1, sequence_size: 4; type :baz }
          end
        end

        expect(bit_fields[0])
          .to have_variable :register, :ral_model, {
            name: 'bit_field_0',
            data_type: :rggen_ral_field,
            random: true
          }
        expect(bit_fields[1])
          .to have_variable :register, :ral_model, {
            name: 'bit_field_1',
            data_type: :rggen_ral_field,
            array_size: [4],
            array_format: :unpacked,
            random: true
          }
        expect(bit_fields[2])
          .to have_variable :register, :ral_model, {
            name: 'bit_field_0',
            data_type: :rggen_bar_field,
            random: true
          }
        expect(bit_fields[3])
          .to have_variable :register, :ral_model, {
            name: 'bit_field_1',
            data_type: :rggen_bar_field,
            array_size: [4],
            array_format: :unpacked,
            random: true
          }
        expect(bit_fields[4])
          .to have_variable :register, :ral_model, {
            name: 'bit_field_0',
            data_type: 'rggen_ral_bit_field_0',
            random: true
          }
        expect(bit_fields[5])
          .to have_variable :register, :ral_model, {
            name: 'bit_field_1',
            data_type: 'rggen_ral_bit_field_1',
            array_size: [4],
            array_format: :unpacked,
            random: true
          }
      end
    end

    describe '#constructors' do
      before(:all) do
        RgGen.define_list_item_feature(:bit_field, :type, :foo) do
          register_map { volatile }
          sv_ral {}
        end
        RgGen.define_list_item_feature(:bit_field, :type, :bar) do
          register_map { non_volatile }
          sv_ral {}
        end
        RgGen.define_list_item_feature(:bit_field, :type, :baz) do
          register_map {}
          sv_ral { access :rw }
        end
      end

      after(:all) do
        delete_register_map_factory
        delete_sv_ral_factory
        RgGen.delete(:bit_field, :type, [:foo, :bar])
      end

      it 'フィールドモデルの生成と構成を行うコードを出力する' do
        bit_fields = create_bit_fields do
          register do
            name 'register_0'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :foo }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8; type :foo }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16; type :foo; initial_value 0 }
            bit_field { name 'bit_field_3'; bit_assignment lsb: 24, width: 8; type :foo; initial_value 0xab }
          end

          register do
            name 'register_1'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :bar }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 1; type :baz }
          end

          register do
            name 'register_2'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8; type :foo }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 4, width: 4, sequence_size: 4, step: 8; type :foo }
          end
        end

        code_block = RgGen::Core::Utility::CodeUtility::CodeBlock.new
        bit_fields.flat_map(&:constructors).each do |constructor|
          code_block << [constructor, "\n"]
        end

        expect(code_block).to match_string(<<~'CODE')
          `rggen_ral_create_field_model(bit_field_0, 0, 1, FOO, 1, 1'h0, 0)
          `rggen_ral_create_field_model(bit_field_1, 8, 8, FOO, 1, 8'h00, 0)
          `rggen_ral_create_field_model(bit_field_2, 16, 1, FOO, 1, 1'h0, 1)
          `rggen_ral_create_field_model(bit_field_3, 24, 8, FOO, 1, 8'hab, 1)
          `rggen_ral_create_field_model(bit_field_0, 0, 1, BAR, 0, 1'h0, 0)
          `rggen_ral_create_field_model(bit_field_1, 1, 1, RW, 1, 1'h0, 0)
          `rggen_ral_create_field_model(bit_field_0[0], 0, 4, FOO, 1, 4'h0, 0)
          `rggen_ral_create_field_model(bit_field_0[1], 8, 4, FOO, 1, 4'h0, 0)
          `rggen_ral_create_field_model(bit_field_0[2], 16, 4, FOO, 1, 4'h0, 0)
          `rggen_ral_create_field_model(bit_field_0[3], 24, 4, FOO, 1, 4'h0, 0)
          `rggen_ral_create_field_model(bit_field_1[0], 4, 4, FOO, 1, 4'h0, 0)
          `rggen_ral_create_field_model(bit_field_1[1], 12, 4, FOO, 1, 4'h0, 0)
          `rggen_ral_create_field_model(bit_field_1[2], 20, 4, FOO, 1, 4'h0, 0)
          `rggen_ral_create_field_model(bit_field_1[3], 28, 4, FOO, 1, 4'h0, 0)
        CODE
      end
    end
  end
end
