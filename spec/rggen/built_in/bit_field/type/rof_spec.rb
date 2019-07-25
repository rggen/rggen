# frozen_string_literal: true

RSpec.describe 'bit_field/type/rof' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, [:name, :size, :type])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :initial_value, :reference, :type])
    RgGen.enable(:bit_field, :type, [:rof])
  end

  describe 'register_map' do
    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    def create_bit_fields(&block)
      create_register_map { register_block(&block) }.bit_fields
    end

    specify 'ビットフィール型は:rof' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 1; type :rof; initial_value 0 }
        end
      end
      expect(bit_fields[0]).to have_property(:type, :rof)
    end

    it '不揮発性ビットフィールである' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 1; type :rof; initial_value 0 }
        end
      end
      expect(bit_fields[0]).to have_property(:volatile?, false)
    end

    specify 'アクセス属性は読み出しのみ可' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 1; type :rof; initial_value 0 }
        end
      end
      expect(bit_fields[0]).to match_access(:read_only)
    end

    specify '初期値の指定は必要' do
      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo; bit_assignment lsb: 1; type :rof }
          end
        end
      }.to raise_register_map_error
    end

    specify '参照ビットフィールドの指定は不要' do
      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo; bit_assignment lsb: 1; type :rof; initial_value 0 }
          end
          register do
            name :bar
            bit_field { name :bar; bit_assignment lsb: 1; type :rof; initial_value 0; reference 'foo.foo' }
          end
        end
      }.not_to raise_error
    end
  end

  describe 'sv_rtl' do
    include_context 'sv rtl common'

    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    before(:all) do
      RgGen.enable(:global, [:bus_width, :address_width])
      RgGen.enable(:register_block, [:name, :byte_size])
      RgGen.enable(:register_block, :sv_rtl_top)
      RgGen.enable(:register, :sv_rtl_top)
      RgGen.enable(:bit_field, :sv_rtl_top)
    end

    after(:all) do
      RgGen.disable(:global, [:bus_width, :address_width])
      RgGen.disable(:register_block, [:name, :byte_size])
    end

    def create_bit_fields(&body)
      create_sv_rtl(&body).bit_fields
    end

    describe '#generate_code' do
      it 'rggen_bit_field_roをインスタンスするコードを出力する' do
        bit_fields = create_bit_fields do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rof; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 16, width: 16; type :rof; initial_value 0xabcd }
          end
        end

        expect(bit_fields[0]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (1)
          ) u_bit_field (
            .bit_field_if (bit_field_sub_if),
            .i_value      (1'h0)
          );
        CODE

        expect(bit_fields[1]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (16)
          ) u_bit_field (
            .bit_field_if (bit_field_sub_if),
            .i_value      (16'habcd)
          );
        CODE
      end
    end
  end

  describe 'sv ral' do
    include_context 'sv ral common'

    before(:all) do
      delete_register_map_factory
    end

    describe '#access' do
      it 'ROを返す' do
        sv_ral = create_sv_ral do
          register do
            name :foo
            bit_field { name :foo; bit_assignment lsb: 1; type :rof; initial_value 0 }
          end
        end

        expect(sv_ral.bit_fields[0].access).to eq 'RO'
      end
    end
  end
end
