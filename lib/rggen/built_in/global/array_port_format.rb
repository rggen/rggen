# frozen_string_literal: true

RgGen.define_simple_feature(:global, :array_port_format) do
  configuration do
    property :array_port_format, default: :packed

    input_pattern /(packed|unpacked|serialized)/i
    ignore_empty_value false

    build do |value|
      @array_port_format =
        if pattern_matched?
          match_data[1].downcase.to_sym
        else
          error "illegal input value for array port format: #{value.inspect}"
        end
    end
  end
end
