# frozen_string_literal: true

RgGen.define_simple_feature(:global, :data_width) do
  configuration do
    property :data_width, default: 32
    property :byte_width, body: -> { data_width / 8 }

    build do |value|
      parse_data_width(value)
      check_data_width_value(value)
    end

    private

    def parse_data_width(value)
      @data_width = Integer(value)
    rescue ArgumentError, TypeError
      error "cannot convert #{value.inspect} into data width"
    end

    def check_data_width_value(value)
      (data_width >= 8) || (
        error "input data width is less than 8: #{value}"
      )
      power_of_2?(data_width) || (
        error "input data width is not power of 2: #{value}"
      )
    end

    def power_of_2?(value)
      value.positive? && (value & value.pred).zero?
    end
  end
end
