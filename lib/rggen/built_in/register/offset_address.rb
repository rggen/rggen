# frozen_string_literal: true

RgGen.define_simple_feature(:register, :offset_address) do
  register_map do
    property :offset_address

    build do |value|
      @offset_address =
        begin
          Integer(value)
        rescue ArgumentError, TypeError
          error "cannot convert #{value.inspect} into offset address"
        end
    end

    verify(:feature) do
      error_condition { !offset_address }
      message { 'no offset address is given' }
    end

    verify(:feature) do
      error_condition { offset_address.negative? }
      message { "offset address is less than 0: #{offset_address}" }
    end

    verify(:feature) do
      error_condition { (offset_address % byte_width).positive? }
      message do
        "offset address is not aligned with data width(#{data_width}): "\
        "0x#{offset_address.to_s(16)}"
      end
    end

    private

    def data_width
      configuration.data_width
    end

    def byte_width
      configuration.byte_width
    end
  end
end
