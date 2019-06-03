# frozen_string_literal: true

RSpec.describe 'bit_field/type' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, :name)
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
        delete_register_map_facotry
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
        delete_register_map_facotry
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

    describe '初期値の有無' do
      before(:all) do
        RgGen.define_list_item_feature(:bit_field, :type, :foo) do
          register_map { need_initial_value }
        end
        RgGen.define_list_item_feature(:bit_field, :type, :bar) do
          register_map {}
        end
        RgGen.define_list_item_feature(:bit_field, :type, :baz) do
          register_map { need_initial_value value: 1 }
        end
        RgGen.define_list_item_feature(:bit_field, :type, :qux) do
          register_map { need_initial_value value: -> { 2**bit_field.width - 1 } }
        end
        RgGen.enable(:bit_field, :type, :qux)
      end

      after(:all) do
        delete_register_map_facotry
        RgGen.delete(:bit_field, :type, [:foo, :bar, :baz, :qux])
        RgGen.disable(:bit_field, :type, :qux)
      end

      context '.need_initial_valueが指定された場合' do
        specify '初期値の指定が必要' do
          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0; type :foo; initial_value 0 }
              end
            end
          }.not_to raise_error

          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0; type :foo }
              end
            end
          }.to raise_register_map_error 'no initial value is given'
        end
      end

      context '.need_initial_valueが指定がない場合' do
        specify '初期値の指定は不要' do
          expect {
            create_bit_fields do
              register do
                name 'bar'
                bit_field { name 'bar'; bit_assignment lsb: 0; type :bar; initial_value 0 }
              end
            end
          }.not_to raise_error

          expect {
            create_bit_fields do
              register do
                name 'bar'
                bit_field { name 'bar'; bit_assignment lsb: 0; type :bar }
              end
            end
          }.not_to raise_error
        end
      end

      describe 'valueオプション' do
        it '適用可能な初期値の値を指定する' do
          expect {
            create_bit_fields do
              register do
                name 'baz'
                bit_field { name 'baz_0'; bit_assignment lsb: 0, width: 1; type :baz; initial_value 1 }
                bit_field { name 'baz_1'; bit_assignment lsb: 1, width: 2; type :baz; initial_value 1 }
              end
            end
          }.not_to raise_error

          expect {
            create_bit_fields do
              register do
                name 'baz'
                bit_field { name 'baz_0'; bit_assignment lsb: 0, width: 1; type :baz; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'value 0x1 is only allowed for initial value: 0x0'

          value = [0, 2, 3].sample
          expect {
            create_bit_fields do
              register do
                name 'baz'
                bit_field { name 'baz_0'; bit_assignment lsb: 0, width: 2; type :baz; initial_value value }
              end
            end
          }.to raise_register_map_error "value 0x1 is only allowed for initial value: 0x#{value.to_s(16)}"
        end

        context 'ブロックが与えられた場合' do
          specify 'ブロックの評価結果が適用可能な初期値の値' do
            expect {
              create_bit_fields do
                register do
                  name 'baz'
                  bit_field { name 'baz_0'; bit_assignment lsb: 0, width: 1; type :qux; initial_value 1 }
                  bit_field { name 'baz_1'; bit_assignment lsb: 1, width: 2; type :qux; initial_value 3 }
                end
              end
            }.not_to raise_error

            expect {
              create_bit_fields do
                register do
                  name 'baz'
                  bit_field { name 'baz_0'; bit_assignment lsb: 0, width: 1; type :qux; initial_value 0 }
                end
              end
            }.to raise_register_map_error 'value 0x1 is only allowed for initial value: 0x0'

            value = [0, 1, 2].sample
            expect {
              create_bit_fields do
                register do
                  name 'baz'
                  bit_field { name 'baz_0'; bit_assignment lsb: 0, width: 2; type :qux; initial_value value }
                end
              end
            }.to raise_register_map_error "value 0x3 is only allowed for initial value: 0x#{value.to_s(16)}"
          end
        end
      end
    end

    describe '参照ビットフィールド' do
      context '.use_refernceが指定された場合' do
        before(:all) do
          RgGen.define_list_item_feature(:bit_field, :type, :foo) do
            register_map { use_reference }
          end
          RgGen.define_list_item_feature(:bit_field, :type, :bar) do
            register_map {}
          end
        end

        after(:all) do
          delete_register_map_facotry
          RgGen.delete(:bit_field, :type, [:foo, :bar])
        end

        specify '参照ビットフィールドの指定は必須ではない' do
          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0; type :foo }
              end
            end
          }.not_to raise_error
        end

        specify '参照ビットフィールドの幅は自身と同じ幅が必要' do
          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0; type :foo; reference 'bar.bar' }
              end
              register do
                name 'bar'
                bit_field { name 'bar'; bit_assignment lsb: 0; type :bar }
              end
            end
          }.not_to raise_error

          width = rand(2..32)
          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0, width: width; type :foo; reference 'bar.bar' }
              end
              register do
                name 'bar'
                bit_field { name 'bar'; bit_assignment lsb: 0, width: width; type :bar }
              end
            end
          }.not_to raise_error

          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0; type :foo; reference 'bar.bar' }
              end
              register do
                name 'bar'
                bit_field { name 'bar'; bit_assignment lsb: 0, width: 2; type :bar }
              end
            end
          }.to raise_register_map_error "1 bit(s) reference bit field is required: bar.bar 2 bit(s)"

          width = rand(2..32)
          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0, width: width; type :foo; reference 'bar.bar' }
              end
              register do
                name 'bar'
                bit_field { name 'bar'; bit_assignment lsb: 0, width: width + 1; type :bar }
              end
            end
          }.to raise_register_map_error "#{width} bit(s) reference bit field is required: bar.bar #{width + 1} bit(s)"

          width = rand(2..32)
          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0, width: width; type :foo; reference 'bar.bar' }
              end
              register do
                name 'bar'
                bit_field { name 'bar'; bit_assignment lsb: 0, width: width - 1; type :bar }
              end
            end
          }.to raise_register_map_error "#{width} bit(s) reference bit field is required: bar.bar #{width - 1} bit(s)"
        end
      end

      context '.use_reference指定時に幅が指定された場合' do
        before(:all) do
          RgGen.define_list_item_feature(:bit_field, :type, :foo) do
            register_map { use_reference width: 2 }
          end
          RgGen.define_list_item_feature(:bit_field, :type, :bar) do
            register_map {}
          end
        end

        after(:all) do
          delete_register_map_facotry
          RgGen.delete(:bit_field, :type, [:foo, :bar])
        end

        specify '参照ビットフィールドは指定された幅でなければならない' do
          [1, 2, 3].each do |foo_width|
            expect {
              create_bit_fields do
                register do
                  name 'foo'
                  bit_field { name 'foo'; bit_assignment lsb: 0, width: foo_width; type :foo; reference 'bar.bar' }
                end
                register do
                  name 'bar'
                  bit_field { name 'bar'; bit_assignment lsb: 0, width: 1; type :bar }
                end
              end
            }.to raise_register_map_error "2 bit(s) reference bit field is required: bar.bar 1 bit(s)"
          end

          [1, 2, 3].each do |foo_width|
            expect {
              create_bit_fields do
                register do
                  name 'foo'
                  bit_field { name 'foo'; bit_assignment lsb: 0, width: foo_width; type :foo; reference 'bar.bar' }
                end
                register do
                  name 'bar'
                  bit_field { name 'bar'; bit_assignment lsb: 0, width: 2; type :bar }
                end
              end
            }.not_to raise_error
          end

          [1, 2, 3].each do |foo_width|
            expect {
              create_bit_fields do
                register do
                  name 'foo'
                  bit_field { name 'foo'; bit_assignment lsb: 0, width: foo_width; type :foo; reference 'bar.bar' }
                end
                register do
                  name 'bar'
                  bit_field { name 'bar'; bit_assignment lsb: 0, width: 3; type :bar }
                end
              end
            }.to raise_register_map_error "2 bit(s) reference bit field is required: bar.bar 3 bit(s)"
          end
        end
      end

      context '.use_referenceがrequired: tureと共に指定された場合' do
        before(:all) do
          RgGen.define_list_item_feature(:bit_field, :type, :foo) do
            register_map { use_reference required: true }
          end
          RgGen.define_list_item_feature(:bit_field, :type, :bar) do
            register_map {}
          end
        end

        after(:all) do
          delete_register_map_facotry
          RgGen.delete(:bit_field, :type, [:foo, :bar])
        end

        specify '参照ビットフィールドの指定が必要' do
          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0; type :foo; reference 'bar.bar' }
              end
              register do
                name 'bar'
                bit_field { name 'bar'; bit_assignment lsb: 0; type :bar }
              end
            end
          }.not_to raise_error

          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo'; bit_assignment lsb: 0; type :foo }
              end
              register do
                name 'bar'
                bit_field { name 'bar'; bit_assignment lsb: 0; type :bar }
              end
            end
          }.to raise_register_map_error 'no reference bit field is given'
        end
      end

      context '.use_referenceが未指定の場合' do
        before(:all) do
          RgGen.define_list_item_feature(:bit_field, :type, [:foo, :bar]) do
            register_map {}
          end
        end

        after(:all) do
          delete_register_map_facotry
          RgGen.delete(:bit_field, :type, [:foo, :bar])
        end

        specify '参照ビットフィールドの幅の確認はされない' do
          expect {
            create_bit_fields do
              register do
                name 'foo'
                bit_field { name 'foo0'; bit_assignment lsb: 0, width: 1; type :foo; reference 'bar.bar0' }
                bit_field { name 'foo1'; bit_assignment lsb: 1, width: 2; type :foo; reference 'bar.bar1' }
              end
              register do
                name 'bar'
                bit_field { name 'bar0'; bit_assignment lsb: 0, width: 2; type :bar }
                bit_field { name 'bar1'; bit_assignment lsb: 2, width: 1; type :bar }
              end
            end
          }.not_to raise_error
        end
      end
    end
  end
end
