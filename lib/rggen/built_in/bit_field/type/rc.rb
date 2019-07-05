# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :rc) do
  register_map do
    read_only
    use_reference
    need_initial_value
  end

  sv_rtl do
    build do
      input :register_block, :set, {
        name: "i_#{full_name}_set",
        data_type: :logic,
        width: bit_field.width,
        array_size: bit_field.array_size,
        array_format: array_port_format
      }
      output :register_block, :value_out, {
        name: "o_#{full_name}",
        data_type: :logic,
        width: bit_field.width,
        array_size: bit_field.array_size,
        array_format: array_port_format
      }
      if bit_field.reference?
        output :register_block, :value_unmasked, {
          name: "o_#{full_name}_unmasked",
          data_type: :logic,
          width: bit_field.width,
          array_size: bit_field.array_size,
          array_format: array_port_format
        }
      end
    end

    main_code :bit_field, from_template: true

    private

    def value_out_unmasked
      (bit_field.reference? || nil) &&
        value_unmasked[bit_field.loop_variables]
    end
  end
end
