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
      error "input data width is less than 8: #{data_width}" if data_width < 8
    end

    verify(:feature) do
      unless power_of_2?(data_width)
        error "input data width is not power of 2: #{data_width}"
      end
    end

    private

    def power_of_2?(value)
      value.positive? && (value & value.pred).zero?
    end
  end
end
