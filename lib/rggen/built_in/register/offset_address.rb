# frozen_string_literal: true

RgGen.define_simple_feature(:register, :offset_address) do
  register_map do
    property :offset_address
    property :address_range, body: -> { start_address..end_address }

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

    verify(:component) do
      error_condition { end_address > register_block.byte_size }
      message do
        'offset address range exceeds byte size of register block' \
        "(#{register_block.byte_size}): " \
        "0x#{start_address.to_s(16)}-0x#{end_address.to_s(16)}"
      end
    end

    verify(:component) do
      error_condition do
        register_block.registers.any? do |register|
          overlap_address_range?(register) &&
            support_unique_range_only?(register)
        end
      end
      message do
        'offset address range overlaps with other offset address range: ' \
        "0x#{start_address.to_s(16)}-0x#{end_address.to_s(16)}"
      end
    end

    private

    def data_width
      configuration.data_width
    end

    def byte_width
      configuration.byte_width
    end

    def start_address
      offset_address
    end

    def end_address
      start_address + register.byte_size - 1
    end

    def overlap_address_range?(other_register)
      overlap_range?(other_register) && match_access?(other_register)
    end

    def overlap_range?(other_register)
      own = address_range
      other = other_register.address_range
      own.include?(other.first) || other.include?(own.first)
    end

    def match_access?(other_register)
      (register.writable? && other_register.writable?) ||
        (register.readable? && other_register.readable?)
    end

    def support_unique_range_only?(other_register)
      !(register.support_overlapped_address? &&
        register.match_type?(other_register))
    end
  end
end
