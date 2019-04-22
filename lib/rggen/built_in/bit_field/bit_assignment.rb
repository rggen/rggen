# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :bit_assignment) do
  register_map do
    property :msb
    property :lsb
    property :width, body: -> { @msb - @lsb + 1 }

    ignore_empty_value false
    input_pattern [
      /\[(?<msb>#{integer})\]/, /\[(?<msb>#{integer}):(?<lsb>#{integer})\]/
    ]

    build do |value|
      @msb, @lsb =
        if pattern_matched?
          [match_data[:msb], match_data[:lsb] || match_data[:msb]].map(&:to_i)
        else
          error "illegal input value for bit assignment: #{value.inspect}"
        end
      validate
    end

    validate do
      error "lsb is larger than msb: msb #{msb} lsb #{lsb}" if lsb > msb
    end

    validate do
      error "lsb is less than 0: lsb #{lsb}" if lsb.negative?
    end

    validate do
      if msb >= data_width
        error 'msb is not less than data width: ' \
              "msb #{msb} data width #{data_width}"
      end
    end

    validate do
      if overlapped_bit_assignment?
        error "overlapped bit assignment: msb #{msb} lsb #{lsb}"
      end
    end

    private

    def data_width
      configuration.data_width
    end

    def overlapped_bit_assignment?
      register
        .bit_fields
        .any? { |f| (f.lsb..f.msb).cover?(lsb) || (lsb..msb).cover?(f.lsb) }
    end
  end
end
