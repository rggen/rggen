# frozen_string_literal: true

RSpec.describe 'bit_field/type/rw' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, [:name, :size, :type])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :initial_value, :reference, :type])
    RgGen.enable(:bit_field, :type, [:rw])
  end

  describe 'register_map' do
    def create_bit_fields(&block)
      create_register_map { register_block(&block) }.bit_fields
    end

    specify 'ビットフィール型は:rw' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 1; type :rw; initial_value 0 }
        end
      end
      expect(bit_fields[0]).to have_property(:type, :rw)
    end

    specify 'アクセス属性は読み書き可' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 1; type :rw; initial_value 0 }
        end
      end
      expect(bit_fields[0]).to match_access(:read_write)
    end

    specify '初期値の指定は必要' do
      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo; bit_assignment lsb: 1; type :rw }
          end
        end
      }.to raise_register_map_error
    end

    specify '参照ビットフィールドの指定は不要' do
      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo; bit_assignment lsb: 1; type :rw; initial_value 0 }
          end
          register do
            name :bar
            bit_field { name :bar; bit_assignment lsb: 1; type :rw; initial_value 0; reference 'foo.foo' }
          end
        end
      }.not_to raise_error
    end
  end
end
