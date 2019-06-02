# frozen_string_literal: true

RSpec.describe 'bit_field/type/reserved' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, :name)
    RgGen.enable(:bit_field, [:name, :bit_assignment, :initial_value, :reference, :type])
    RgGen.enable(:bit_field, :type, [:reserved, :rw])
  end

  describe 'register_map' do
    def create_bit_fields(&block)
      create_register_map { register_block(&block) }.bit_fields
    end

    specify 'ビットフィール型は:reserved' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 1; type :reserved }
        end
      end
      expect(bit_fields[0]).to have_property(:type, :reserved)
    end

    specify 'アクセス属性は予約済み属性' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 1; type :reserved }
        end
      end
      expect(bit_fields[0]).to match_access(:reserved)
    end

    specify '初期値の指定は不要' do
      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo; bit_assignment lsb: 1; type :reserved; initial_value 0 }
          end
          register do
            name :bar
            bit_field { name :bar; bit_assignment lsb: 1; type :reserved }
          end
        end
      }.not_to raise_error
    end

    specify '参照ビットフィールドの指定は不要' do
      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo; bit_assignment lsb: 1; type :reserved }
          end
          register do
            name :bar
            bit_field { name :bar; bit_assignment lsb: 1; type :reserved; reference 'baz.baz' }
          end
          register do
            name :baz
            bit_field { name :baz; bit_assignment lsb: 1; type :rw; initial_value 0 }
          end
        end
      }.not_to raise_error
    end
  end
end
