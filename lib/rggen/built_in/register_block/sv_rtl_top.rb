# frozen_string_literal: true

RgGen.define_simple_feature(:register_block, :sv_rtl_top) do
  sv_rtl do
    export :total_registers

    build do
      input :register_block, :clock, {
        name: 'i_clk', data_type: :logic, width: 1
      }
      input :register_block, :reset, {
        name: 'i_rst_n', data_type: :logic, width: 1
      }
      interface :register_block, :register_if, {
        name: 'register_if', interface_type: 'rggen_register_if',
        parameter_values: [address_width, bus_width, value_width],
        array_size: [total_registers],
        variables: ['value']
      }
    end

    write_file '<%= register_block.name %>.sv' do |file|
      file.body(&method(:body_code))
    end

    def total_registers
      register_block
        .registers
        .map(&:count)
        .inject(:+)
    end

    private

    def address_width
      register_block.local_address_width
    end

    def bus_width
      configuration.bus_width
    end

    def value_width
      register_block.registers.map(&:width).max
    end

    def body_code(code)
      macro_definition(code)
      sv_module_definition(code)
    end

    def macro_definition(code)
      code << process_template(File.join(__dir__, 'sv_rtl_macros.erb'))
    end

    def sv_module_definition(code)
      code << module_definition(register_block.name) do |sv_module|
        sv_module.package_imports packages
        sv_module.parameters parameters
        sv_module.ports ports
        sv_module.variables variables
        sv_module.body(&method(:sv_module_body))
      end
    end

    def packages
      ['rggen_rtl_pkg', *register_block.package_imports(:register_block)]
    end

    def parameters
      register_block.declarations(:register_block, :parameter)
    end

    def ports
      register_block.declarations(:register_block, :port)
    end

    def variables
      register_block.declarations(:register_block, :variable)
    end

    def sv_module_body(code)
      register_block.generate_code(:register_block, :top_down, code)
    end
  end
end
