# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, [:w0s, :w1s]) do
  register_map do
    read_write
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
      input :register_block, :clear, {
        name: "i_#{full_name}_clear",
        data_type: :logic,
        width: bit_field.width,
        array_size: bit_field.array_size,
        array_format: array_port_format
      }
    end

    main_code :bit_field, from_template: true

    private

    def set_value
      bin({ w0s: 0, w1s: 1 }[bit_field.type], 1)
    end
  end
end
