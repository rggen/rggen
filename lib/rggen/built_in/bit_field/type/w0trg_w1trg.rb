# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, [:w0trg, :w1trg]) do
  register_map do
    write_only
    non_volatile
  end

  sv_rtl do
    build do
      output :register_block, :trigger, {
        name: "o_#{full_name}_trigger", data_type: :logic, width: width,
        array_size: array_size, array_format: array_port_format
      }
    end

    main_code :bit_field, from_template: true

    private

    def trigger_value
      bin({ w0trg: 0, w1trg: 1 }[bit_field.type], 1)
    end
  end

  sv_ral do
    model_name { "rggen_ral_#{bit_field.type}_field" }
  end
end
