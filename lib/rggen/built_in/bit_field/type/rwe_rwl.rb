# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, [:rwe, :rwl]) do
  register_map do
    read_write
    volatile? { !bit_field.reference? }
    need_initial_value
    use_reference width: 1
  end

  sv_rtl do
    build do
      if enable_port?
        input :register_block, :enable, {
          name: "i_#{full_name}_enable",
          data_type: :logic,
          width: 1,
          array_size: bit_field.array_size,
          array_format: array_port_format
        }
      end
      if lock_port?
        input :register_block, :lock, {
          name: "i_#{full_name}_lock",
          data_type: :logic,
          width: 1,
          array_size: bit_field.array_size,
          array_format: array_port_format
        }
      end
      output :register_block, :value_out, {
        name: "o_#{full_name}",
        data_type: :logic,
        width: bit_field.width,
        array_size: bit_field.array_size,
        array_format: array_port_format
      }
    end

    main_code :bit_field, from_template: true

    private

    def enable_port?
      bit_field.type == :rwe && !bit_field.reference?
    end

    def lock_port?
      bit_field.type == :rwl && !bit_field.reference?
    end

    def control_signal
      if enable_port?
        enable[bit_field.loop_variables]
      elsif lock_port?
        lock[bit_field.loop_variables]
      else
        reference_bit_field
      end
    end
  end

  sv_ral do
    model_name do
      "rggen_ral_#{bit_field.type}_field #(#{reference_names})"
    end

    private

    def reference_names
      reference = bit_field.reference
      register = reference&.register
      [register&.name, reference&.name]
        .map { |name| string(name) }
        .join(', ')
    end
  end
end
