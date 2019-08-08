# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :rw) do
  register_map do
    read_write
    non_volatile
    initial_value require: true
  end
end

RgGen.define_list_item_feature(:bit_field, :type, :wo) do
  register_map do
    write_only
    non_volatile
    initial_value require: true
  end
end

RgGen.define_list_item_feature(:bit_field, :type, [:rw, :wo]) do
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
