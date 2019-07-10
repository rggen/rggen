# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :sv_rtl_top) do
  sv_rtl do
    export :local_index
    export :loop_variables
    export :array_size
    export :value

    build do
      interface :bit_field, :bit_field_sub_if, {
        name: 'bit_field_sub_if',
        interface_type: 'rggen_bit_field_if',
        parameter_values: [bit_field.width]
      }
    end

    main_code :register do
      local_scope(block_name, loop_size: loop_size, variables: variables) do
        body { |code| bit_field.generate_code(:bit_field, :top_down, code) }
      end
    end

    pre_code :bit_field do |code|
      code << bit_field_if_connection << nl
    end

    def local_index
      (bit_field.sequential? || nil) &&
        create_identifier(index_name)
    end

    def index_name
      depth = (register.loop_variables&.size || 0) + 1
      loop_index(depth)
    end

    def loop_variables
      (inside_loop? || nil) &&
        [*register.loop_variables, local_index].compact
    end

    def array_size
      (inside_loop? || nil) &&
        [*register.array_size, bit_field.sequence_size].compact
    end

    def value
      register_block
        .register_if[register.index]
        .value[bit_field.lsb(local_index), bit_field.width]
    end

    private

    def inside_loop?
      register.array? || bit_field.sequential?
    end

    def block_name
      "g_#{bit_field.full_name('_')}"
    end

    def loop_size
      (bit_field.sequential? || nil) &&
        { index_name => bit_field.sequence_size }
    end

    def variables
      bit_field.declarations(:bit_field, :variable)
    end

    def bit_field_if_connection
      macro_call(
        :rggen_connect_bit_field_if,
        [
          register.bit_field_if,
          bit_field.bit_field_sub_if,
          bit_field.lsb(local_index),
          bit_field.width
        ]
      )
    end
  end
end
