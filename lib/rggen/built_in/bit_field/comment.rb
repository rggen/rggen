# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :comment) do
  register_map do
    property :comment, body: -> { @comment ||= '' }

    build do |value|
      @comment =
        if value.is_a?(Array)
          value.join("\n")
        else
          value.to_s
        end
    end
  end
end
