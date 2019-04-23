# frozen_string_literal: true

RgGen.define_simple_feature(:global, :address_width) do
  configuration do
    property :address_width, default: 32

    build do |value|
      @address_width =
        begin
          Integer(value)
        rescue ArgumentError, TypeError
          error "cannot convert #{value.inspect} into address width"
        end
    end

    verify(:all) do
      if address_width < min_address_width
        error 'input address width is less than minimum address width: ' \
              "address width #{address_width} " \
              "minimum address width #{min_address_width}"
      end
    end

    private

    def min_address_width
      byte_width = configuration.byte_width
      byte_width == 1 ? 1 : (byte_width - 1).bit_length
    end
  end
end
