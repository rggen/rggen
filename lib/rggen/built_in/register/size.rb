# frozen_string_literal: true

RgGen.define_simple_feature(:register, :size) do
  register_map do
    property :size

    input_pattern [
      /(#{integer}(:?,#{integer})*)/,
      /\[(#{integer}(:?,#{integer})*)\]/
    ], match_automatically: false

    build do |values|
      @size = parse_values(values)
    end

    verify(:feature) do
      error_condition { size && !size.all?(&:positive?) }
      message do
        "non positive value(s) are not allowed for register size: #{size}"
      end
    end

    private

    def parse_values(values)
      Array(
        values.is_a?(String) && parse_string_values(values) || values
      ).map(&method(:convert_value))
    end

    def parse_string_values(values)
      if match_pattern(values)
        split_match_data(match_data)
      else
        error "illegal input value for register size: #{values.inspect}"
      end
    end

    def split_match_data(match_data)
      match_data.captures.first.split(',')
    end

    def convert_value(value)
      Integer(value)
    rescue ArgumentError, TypeError
      error "cannot convert #{value.inspect} into register size"
    end
  end
end
