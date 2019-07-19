# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, [:rwe, :rwl]) do
  register_map do
    read_write
    non_volatile
    need_initial_value
    use_reference required: true, width: 1
  end

  sv_rtl do
    build do
      output :register_block, :value_out, {
        name: "o_#{full_name}",
        data_type: :logic,
        width: bit_field.width,
        array_size: bit_field.array_size,
        array_format: array_port_format
      }
    end

    main_code :bit_field, from_template: true
  end

  sv_ral do
    model_name do
      "rggen_ral_#{bit_field.type}_field #(#{reference_names})"
    end

    private

    def reference_names
      reference = bit_field.find_reference(register_block.bit_fields)
      [reference.register.name, reference.name]
        .map { |name| string(name) }
        .join(', ')
    end
  end
end
