# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :rs) do
  register_map do
    read_only
    need_initial_value
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
end
