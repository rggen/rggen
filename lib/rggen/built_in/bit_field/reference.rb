# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :reference) do
  register_map do
    property :reference, forward_to: :reference_bit_field, verify: :all
    property :reference?, body: -> { use_reference? && !no_reference? }
    property :reference_width, forward_to: :required_width
    property :find_reference, forward_to: :find_reference_bit_field

    input_pattern /(#{variable_name})\.(#{variable_name})/

    build do |value|
      @input_reference =
        if pattern_matched?
          "#{match_data[1]}.#{match_data[2]}"
        else
          error "illegal input value for reference: #{value.inspect}"
        end
    end

    verify(:component) do
      error_condition { require_reference? && no_reference? }
      message { 'no reference bit field is given' }
    end

    verify(:component) do
      error_condition { reference? && @input_reference == bit_field.full_name }
      message { "self reference: #{@input_reference}" }
    end

    verify(:all) do
      error_condition { reference? && !reference_bit_field }
      message { "no such bit field found: #{@input_reference}" }
    end

    verify(:all) do
      error_condition do
        reference? && !register.array? && reference_bit_field.register.array?
      end
      message do
        'bit field of array register is not allowed for ' \
        "reference bit field: #{@input_reference}"
      end
    end

    verify(:all) do
      error_condition { reference? && !match_array_size? }
      message do
        'array size is not matched: ' \
        "own #{register.array_size} " \
        "reference #{reference_bit_field.register.array_size}"
      end
    end

    verify(:all) do
      error_condition do
        reference? && !bit_field.sequential? && reference_bit_field.sequential?
      end
      message do
        'sequential bit field is not allowed for ' \
        "reference bit field: #{@input_reference}"
      end
    end

    verify(:all) do
      error_condition { reference? && !match_sequence_size? }
      message do
        'sequence size is not matched: ' \
        "own #{bit_field.sequence_size} " \
        "reference #{reference_bit_field.sequence_size}"
      end
    end

    verify(:all) do
      error_condition { reference? && reference_bit_field.reserved? }
      message { "refer to reserved bit field: #{@input_reference}" }
    end

    verify(:all) do
      error_condition { reference? && !match_width? }
      message do
        "#{required_width} bits reference bit field is required: " \
        "#{reference_bit_field.width} bit(s) width"
      end
    end

    private

    def option
      @option ||=
        (bit_field.options && bit_field.options[:reference]) || {}
    end

    def use_reference?
      option.fetch(:use, true)
    end

    def require_reference?
      use_reference? && option[:require]
    end

    def no_reference?
      @input_reference.nil?
    end

    def reference_bit_field
      (reference? || nil) &&
        (@reference_bit_field ||= lookup_reference)
    end

    def find_reference_bit_field(bit_fields)
      (reference? || nil) &&
        bit_fields
          .find { |bit_field| bit_field.full_name == @input_reference }
    end

    def lookup_reference
      find_reference_bit_field(register_block.bit_fields)
    end

    def match_array_size?
      !(register.array? && reference_bit_field.register.array?) ||
        register.array_size == reference_bit_field.register.array_size
    end

    def match_sequence_size?
      !(bit_field.sequential? && reference_bit_field.sequential?) ||
        bit_field.sequence_size == reference_bit_field.sequence_size
    end

    def required_width
      option[:width] || bit_field.width
    end

    def match_width?
      reference_bit_field.width >= required_width
    end
  end
end
