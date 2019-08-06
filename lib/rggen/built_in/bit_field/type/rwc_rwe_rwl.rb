# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, [:rwc, :rwe, :rwl]) do
  register_map do
    read_write
    volatile? { bit_field.type == :rwc || !bit_field.reference? }
    need_initial_value
    use_reference width: 1
  end

  sv_rtl do
    build do
      if clear_port?
        input :register_block, :clear, {
          name: "i_#{full_name}_clear",
          data_type: :logic,
          width: 1,
          array_size: bit_field.array_size,
          array_format: array_port_format
        }
      end
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

    def clear_port?
      bit_field.type == :rwc && !bit_field.reference?
    end

    def enable_port?
      bit_field.type == :rwe && !bit_field.reference?
    end

    def lock_port?
      bit_field.type == :rwl && !bit_field.reference?
    end

    def control_signal
      reference_bit_field || control_port[bit_field.loop_variables]
    end

    def control_port
      case bit_field.type
      when :rwc
        clear
      when :rwe
        enable
      when :rwl
        lock
      end
    end
  end
end

RgGen.define_list_item_feature(:bit_field, :type, :rwc) do
  sv_ral do
    access 'RW'
  end
end

RgGen.define_list_item_feature(:bit_field, :type, [:rwe, :rwl]) do
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
