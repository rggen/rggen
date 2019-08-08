# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :rc) do
  register_map do
    read_only
    reference use: true
    initial_value require: true
  end
end

RgGen.define_list_item_feature(:bit_field, :type, [:w0c, :w1c]) do
  register_map do
    read_write
    reference use: true
    initial_value require: true
  end
end

RgGen.define_list_item_feature(:bit_field, :type, [:rc, :w0c, :w1c]) do
  sv_rtl do
    build do
      input :register_block, :set, {
        name: "i_#{full_name}_set", data_type: :logic, width: width,
        array_size: array_size, array_format: array_port_format
      }
      output :register_block, :value_out, {
        name: "o_#{full_name}", data_type: :logic, width: width,
        array_size: array_size, array_format: array_port_format
      }
      if bit_field.reference?
        output :register_block, :value_unmasked, {
          name: "o_#{full_name}_unmasked", data_type: :logic, width: width,
          array_size: array_size, array_format: array_port_format
        }
      end
    end

    main_code :bit_field, from_template: true

    private

    def module_name
      if bit_field.type == :rc
        'rggen_bit_field_rc'
      else
        'rggen_bit_field_w01c'
      end
    end

    def clear_value
      bin({ w0c: 0, w1c: 1 }[bit_field.type], 1)
    end

    def value_out_unmasked
      (bit_field.reference? || nil) &&
        value_unmasked[loop_variables]
    end
  end
end
