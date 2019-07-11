# frozen_string_literal: true

RSpec.describe 'bit_field/type/reserved' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, [:name, :size, :type])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :initial_value, :reference, :type])
    RgGen.enable(:bit_field, :type, [:reserved, :rw])
  end

  describe 'register_map' do
    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

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

  describe 'sv rtl' do
    include_context 'sv rtl common'

    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    before(:all) do
      RgGen.enable(:global, [:bus_width, :address_width, :array_port_format])
      RgGen.enable(:register_block, [:name, :byte_size])
      RgGen.enable(:register, :sv_rtl_top)
      RgGen.enable(:bit_field, :sv_rtl_top)
    end

    after(:all) do
      RgGen.disable(:global, [:bus_width, :address_width, :array_port_format])
      RgGen.disable(:register_block, [:name, :byte_size])
    end

    def create_bit_fields(&body)
      create_sv_rtl(&body).bit_fields
    end

    describe '#generate_code' do
      it 'rggen_bit_field_reservedをインスタンスするコードを出力する' do
        bit_fields = create_bit_fields do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :reserved }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 16, width: 16; type :reserved }
          end

          register do
            name 'register_1'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 64; type :reserved }
          end

          register do
            name 'register_2'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8; type :reserved }
          end

          register do
            name 'register_3'
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8; type :reserved }
          end

          register do
            name 'register_4'
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8; type :reserved }
          end
        end

        expect(bit_fields[0]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_reserved u_bit_field (
            .bit_field_if (bit_field_sub_if)
          );
        CODE

        expect(bit_fields[1]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_reserved u_bit_field (
            .bit_field_if (bit_field_sub_if)
          );
        CODE

        expect(bit_fields[2]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_reserved u_bit_field (
            .bit_field_if (bit_field_sub_if)
          );
        CODE

        expect(bit_fields[3]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_reserved u_bit_field (
            .bit_field_if (bit_field_sub_if)
          );
        CODE

        expect(bit_fields[4]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_reserved u_bit_field (
            .bit_field_if (bit_field_sub_if)
          );
        CODE

        expect(bit_fields[5]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_reserved u_bit_field (
            .bit_field_if (bit_field_sub_if)
          );
        CODE
      end
    end
  end
end
