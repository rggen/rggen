# frozen_string_literal: true

RgGen.define_simple_feature(:register_block, :byte_size) do
  register_map do
    property :byte_size

    build do |value|
      @byte_size =
        begin
          Integer(value)
        rescue ArgumentError, TypeError
          error "cannot convert #{value.inspect} into byte size"
        end
    end

    verify(:feature) do
      error_condition { !byte_size }
      message { 'no byte size is given' }
    end

    verify(:feature) do
      error_condition { !byte_size.positive? }
      message do
        "non positive value is not allowed for byte size: #{byte_size}"
      end
    end

    verify(:feature) do
      error_condition { byte_size > max_byte_size }
      message do
        'input byte size is greater than maximum byte size: ' \
        "input byte size #{byte_size} maximum byte size #{max_byte_size}"
      end
    end

    verify(:feature) do
      error_condition { (byte_size % byte_width).positive? }
      message do
        "byte size is not aligned with data width(#{data_width}): #{byte_size}"
      end
    end

    private

    def max_byte_size
      2**configuration.address_width
    end

    def byte_width
      configuration.byte_width
    end

    def data_width
      configuration.data_width
    end
  end
end
