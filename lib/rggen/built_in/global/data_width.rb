# frozen_string_literal: true

RgGen.define_simple_feature(:global, :data_width) do
  configuration do
    property :data_width, default: 32
    property :byte_width, body: -> { data_width / 8 }

    build do |value|
      @data_width =
        begin
          Integer(value)
        rescue ArgumentError, TypeError
          error "cannot convert #{value.inspect} into data width"
        end
    end

    verify(:feature) do
      error_condition { data_width < 8 }
      message { "input data width is less than 8: #{data_width}" }
    end

    verify(:feature) do
      error_condition { !power_of_2?(data_width) }
      message { "input data width is not power of 2: #{data_width}" }
    end

    private

    def power_of_2?(value)
      value.positive? && (value & value.pred).zero?
    end
  end
end
