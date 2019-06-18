# frozen_string_literal: true

RgGen.define_simple_feature(:register_block, :sv_rtl_top) do
  sv_rtl do
    build do
      input :register_block, :clock, {
        name: 'i_clk',
        data_type: :logic,
        width: 1
      }
      input :register_block, :reset, {
        name: 'i_rst_n',
        data_type: :logic,
        width: 1
      }
      interface :register_block, :register_if, {
        name: 'register_if',
        interface_type: 'rggen_register_if',
        parameter_values: [address_width, data_width],
        array_size: [total_registers],
        variables: ['value']
      }
    end

    private

    def address_width
      register_block.local_address_width
    end

    def data_width
      configuration.data_width
    end

    def total_registers
      register_block
        .registers
        .map(&:count)
        .inject(:+)
    end
  end
end
