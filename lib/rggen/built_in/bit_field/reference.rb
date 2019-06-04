# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :reference) do
  register_map do
    property :reference, forward_to: :reference_bit_field, verify: :all
    property :reference?, body: -> { !@input_reference.nil? }

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
      error_condition { reference? && @input_reference == bit_field.full_name }
      message { "self reference: #{@input_reference}" }
    end

    verify(:all) do
      error_condition { reference? && !reference_bit_field }
      message { "no such bit field found: #{@input_reference}" }
    end

    verify(:all) do
      error_condition { reference? && reference_bit_field.register.array? }
      message do
        'bit field of array register is not allowed for ' \
        "reference bit field: #{@input_reference}"
      end
    end

    verify(:all) do
      error_condition { reference? && reference_bit_field.sequential? }
      message do
        'sequential bit field is not allowed for ' \
        "reference bit field: #{@input_reference}"
      end
    end

    verify(:all) do
      error_condition { reference? && lookup_reference.reserved? }
      message { "refer to reserved bit field: #{@input_reference}" }
    end

    private

    def reference_bit_field
      reference? && (@reference_bit_field ||= lookup_reference) || nil
    end

    def lookup_reference
      register_block.bit_fields
        .find { |bit_field| bit_field.full_name == @input_reference }
    end
  end
end
