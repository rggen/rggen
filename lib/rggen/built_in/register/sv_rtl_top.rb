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
        @loop_variables ||=
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
  end
end
