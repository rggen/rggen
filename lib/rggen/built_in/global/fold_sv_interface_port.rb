# frozen_string_literal: true

RgGen.define_simple_feature(:global, :fold_sv_interface_port) do
  configuration do
    property :fold_sv_interface_port?, default: true

    input_pattern [
      /true|on|yes/i, /false|off|no/i
    ], match_automatically: false

    ignore_empty_value false

    build do |value|
      @fold_sv_interface_port =
        if [true, false].include?(value)
          value
        elsif match_pattern(value)
          [true, false][match_index]
        else
          error "cannot convert #{value.inspect} into boolean"
        end
    end
  end
end
