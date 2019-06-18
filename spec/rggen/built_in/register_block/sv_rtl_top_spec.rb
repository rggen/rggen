# frozen_string_literal: true

RSpec.describe 'register_block/sv_rtl_top' do
  include_context 'sv rtl common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, [:data_width, :address_width])
    RgGen.enable(:register_block, [:name, :byte_size])
    RgGen.enable(:register, [:name, :offset_address, :size, :type])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
    RgGen.enable(:bit_field, :type, :rw)
    RgGen.enable(:register_block, :sv_rtl_top)
  end

  def create_register_block(&body)
    create_sv_rtl(&body).register_blocks.first
  end

  let(:data_width) { default_configuration.data_width }

  let(:address_width) { 8 }

  describe 'clock/reset' do
    it 'clock/resetを持つ' do
      register_block = create_register_block { name 'block_0'; byte_size 256 }
      expect(register_block)
        .to have_port(:register_block, :clock) { name 'i_clk'; direction :input; data_type :logic; width 1; }
      expect(register_block)
        .to have_port(:register_block, :reset) { name 'i_rst_n'; direction :input; data_type :logic; width 1; }
    end
  end

  describe 'register_if' do
    it 'レジスタの個数分のrggen_register_ifのインスタンスを持つ' do
      register_block = create_register_block do
        name 'block_0'
        byte_size 256
        register do
          name 'register_0'
          offset_address 0x00
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
      end
      expect(register_block)
        .to have_interface :register_block, :register_if, {
          name: 'register_if',
          interface_type: 'rggen_register_if',
          parameter_values: [address_width, data_width],
          array_size: [1]
        }

      register_block = create_register_block do
        name 'block_0'
        byte_size 256
        register do
          name 'register_0'
          offset_address 0x00
          size [2, 4]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
      end
      expect(register_block)
        .to have_interface :register_block, :register_if, {
          name: 'register_if',
          interface_type: 'rggen_register_if',
          parameter_values: [address_width, data_width],
          array_size: [8]
        }
    end

    specify '内部信号\'value\'を参照できる' do
      register_block = create_register_block do
        name 'block_0'
        byte_size 256
        register do
          name 'register_0'
          offset_address 0x00
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
      end
      expect(register_block.register_if[0].value).to match_identifier('register_if[0].value')
    end
  end
end
