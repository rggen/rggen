# frozen_string_literal: true

RgGen.define_simple_feature(:global, :address_width) do
  configuration do
    property :address_width, default: 32

    build do |value|
      @address_width = parse_address_width(value)
    end

    validate do
      (address_width >= min_address_width) || (
        error "input address width is less than #{min_address_width}: " \
              "#{address_width}"
      )
    end

    private

    def parse_address_width(value)
      Integer(value)
    rescue ArgumentError, TypeError
      error "cannot convert #{value.inspect} into address width"
    end

    def min_address_width
      byte_width = configuration.byte_width
      byte_width == 1 ? 1 : (byte_width - 1).bit_length
    end
  end
end
