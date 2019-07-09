# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :rs) do
  register_map do
    read_only
    need_initial_value
  end
end

RgGen.define_list_item_feature(:bit_field, :type, [:w0s, :w1s]) do
  register_map do
    read_write
    need_initial_value
  end
end

RgGen.define_list_item_feature(:bit_field, :type, [:rs, :w0s, :w1s]) do
  sv_rtl do
    build do
      input :register_block, :clear, {
        name: "i_#{full_name}_clear",
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
    end

    main_code(:bit_field) { process_template(template_path) }

    private

    def template_path
      erb = (bit_field.type == :rs) ? 'rs.erb' : 'w01s.erb'
      File.join(__dir__, erb)
    end

    def set_value
      bin({ w0s: 0, w1s: 1 }[bit_field.type], 1)
    end
  end
end
