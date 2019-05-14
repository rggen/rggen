# frozen_string_literal: true

RSpec.describe 'bit_field/reference' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.define_simple_feature(:bit_field, :reserved) do
      register_map do
        property :reserved?, default: false
        build { |value| @reserved = value }
      end
    end
  end

  before(:all) do
    RgGen.enable(:register, :name)
    RgGen.enable(:bit_field, [:name, :reference, :reserved])
  end

  after(:all) do
    RgGen.delete(:bit_field, :reserved)
  end

  def create_bit_fields(&block)
    create_register_map { register_block(&block) }.bit_fields
  end

  describe '#reference' do
    it '指定された参照ビットフィールドを返す' do
      bit_fields = create_bit_fields do
        register do
          name 'foo_0'
          bit_field { name 'foo_0_0'; reference 'foo_0.foo_0_1' }
          bit_field { name 'foo_0_1' }
        end
      end
      expect(bit_fields[0]).to have_property(:reference, equal(bit_fields[1]))

      bit_fields = create_bit_fields do
        register do
          name 'foo_0'
          bit_field { name 'foo_0_0' }
          bit_field { name 'foo_0_1'; reference 'foo_0.foo_0_0' }
        end
      end
      expect(bit_fields[1]).to have_property(:reference, equal(bit_fields[0]))

      bit_fields = create_bit_fields do
        register do
          name 'foo_0'
          bit_field { name 'foo_0_0' }
        end
        register do
          name 'foo_1'
          bit_field { name 'foo_1_0'; reference 'foo_0.foo_0_0' }
        end
      end
      expect(bit_fields[1]).to have_property(:reference, equal(bit_fields[0]))

      bit_fields = create_bit_fields do
        register do
          name 'foo_0'
          bit_field { name 'foo_0_0'; reference 'foo_1.foo_1_0' }
        end
        register do
          name 'foo_1'
          bit_field { name 'foo_1_0' }
        end
      end
      expect(bit_fields[0]).to have_property(:reference, equal(bit_fields[1]))
    end

    context '参照ビットフィールドが指定されていない場合' do
      specify '呼び出してもエラーにならない' do
        bit_fields = create_bit_fields do
          register do
            name 'foo_0'
            bit_field { name 'foo_0_0' }
            bit_field { name 'foo_0_1'; reference '' }
            bit_field { name 'foo_0_2'; reference nil }
          end
        end
        expect {
          bit_fields[0].reference
          bit_fields[1].reference
          bit_fields[2].reference
        }.not_to raise_error
      end
    end
  end

  describe '#reference?' do
    it '参照ビットフィールドを持つかどうかを示す' do
      bit_fields = create_bit_fields do
        register do
          name 'foo_0'
          bit_field { name 'foo_0_0'; reference 'foo_0.foo_0_1' }
          bit_field { name 'foo_0_1' }
        end
      end
      expect(bit_fields[0]).to have_property(:reference?, true)
      expect(bit_fields[1]).to have_property(:reference?, false)
    end
  end

  describe 'エラーチェック' do
    context '参照ビットフィールド名が入力パターンに合致しない場合' do
      it 'RegisterMapErrorを起こす' do
        [
          0,
          '0foo',
          'foo',
          'foo.0',
          'foo.0bar',
          'foo/bar',
          'foo?.bar',
          'foo.bar?',
          'foo bar'
        ].each do |input_value|
          expect {
            create_bit_fields do
              register do
                name 'foo_0'
                bit_field { name 'foo_0_0'; reference input_value }
              end
            end
          }.to raise_register_map_error "illegal input value for reference: #{input_value.inspect}"
        end
      end
    end

    context '自分自身を参照している場合' do
      it 'RegisterMapErrorを起こす' do
        expect {
          create_bit_fields do
            register do
              name 'foo_0'
              bit_field { name 'foo_0_0'; reference 'foo_0.foo_0_0' }
            end
          end
        }.to raise_register_map_error 'self reference: foo_0.foo_0_0'
      end
    end

    context '参照ビットフィールドが存在しない場合' do
      it 'RegisterMapErrorを起こす' do
        expect {
          create_bit_fields do
            register do
              name 'foo_0'
              bit_field { name 'foo_0_0'; reference 'foo_1.foo_1_1' }
            end
            register do
              name 'foo_1'
              bit_field { name 'foo_1_0' }
            end
          end
        }.to raise_register_map_error 'no such bit field found: foo_1.foo_1_1'

        expect {
          create_bit_fields do
            register do
              name 'foo_0'
              bit_field { name 'foo_0_0'; reference 'foo_2.foo_1_0' }
            end
            register do
              name 'foo_1'
              bit_field { name 'foo_1_0' }
            end
          end
        }.to raise_register_map_error 'no such bit field found: foo_2.foo_1_0'

        expect {
          create_bit_fields do
            register do
              name 'foo_0'
              bit_field { name 'foo_0_0'; reference 'foo_3.foo_3_0' }
            end
            register do
              name 'foo_1'
              bit_field { name 'foo_1_0' }
            end
          end
        }.to raise_register_map_error 'no such bit field found: foo_3.foo_3_0'
      end
    end

    context '予約済みビットフィールドを参照してる場合' do
      it 'RegisterMapErrorを起こす' do
        expect {
          create_bit_fields do
            register do
              name 'foo_0'
              bit_field { name 'foo_0_0'; reference 'foo_1.foo_1_0' }
            end
            register do
              name 'foo_1'
              bit_field { name 'foo_1_0'; reserved true }
            end
          end
        }.to raise_register_map_error 'refer to reserved bit field: foo_1.foo_1_0'
      end
    end
  end
end
