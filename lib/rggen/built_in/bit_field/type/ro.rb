# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :ro) do
  register_map do
    read_only
    use_reference
  end

  sv_rtl do
    build do
      input :register_block, :value_in, {
        name: "i_#{full_name}",
        data_type: :logic,
        width: bit_field.width,
        array_size: bit_field.array_size,
        array_format: array_port_format
      }
    end

    main_code :bit_field, from_template: true

    private

    def mask
      reference_bit_field ||
        hex(2**bit_field.width - 1, bit_field.width)
    end
  end
end
