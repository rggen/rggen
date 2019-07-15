# frozen_string_literal: true

RgGen.define_simple_feature(:register, :sv_rtl_top) do
  sv_rtl do
    export :index
    export :local_index
    export :loop_variables

    pre_build do
      @base_index =
        register_block.registers.map(&:count).inject(0, :+)
    end

    build do
      if register.bit_fields?
        interface :register, :bit_field_if, {
          name: 'bit_field_if',
          interface_type: 'rggen_bit_field_if',
          parameter_values: [register.width]
        }
      end
    end

    main_code :register_block do
      local_scope(block_name, loop_size: loop_size, variables: variables) do
        top_scope
        body { |code| register.generate_code(:register, :top_down, code) }
      end
    end

    def index
      register.array? ? "#{@base_index}+#{local_index}" : @base_index
    end

    def local_index
      (register.array? || nil) &&
        loop_variables
          .zip(local_index_coefficients)
          .map { |v, c| [c, v].compact.join('*') }
          .join('+')
    end

    def loop_variables
      (register.array? || nil) &&
        Array.new(register.array_size.size) do |i|
          create_identifier(loop_index(i + 1))
        end
    end

    private

    def local_index_coefficients
      coefficients = []
      register.array_size.reverse.inject(1) do |total, size|
        coefficients.unshift(coefficients.size.zero? ? nil : total)
        total * size
      end
      coefficients
    end

    def block_name
      "g_#{register.name}"
    end

    def loop_size
      (register.array? || nil) &&
        loop_variables.zip(register.array_size).to_h
    end

    def variables
      register.declarations(:register, :variable)
    end
  end
end
