# frozen_string_literal: true

RgGen.define_simple_feature(:global, :bus_width) do
  configuration do
    property :bus_width, default: 32
    property :byte_width, initial: -> { bus_width / 8 }

    build do |value|
      @bus_width =
        begin
          Integer(value)
        rescue ArgumentError, TypeError
          error "cannot convert #{value.inspect} into bus width"
        end
    end

    verify(:feature) do
      error_condition { bus_width < 8 }
      message { "input bus width is less than 8: #{bus_width}" }
    end

    verify(:feature) do
      error_condition { !power_of_2?(bus_width) }
      message { "input bus width is not power of 2: #{bus_width}" }
    end

    printable :bus_width

    private

    def power_of_2?(value)
      value.positive? && (value & value.pred).zero?
    end
  end
end
