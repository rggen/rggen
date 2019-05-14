# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :reference) do
  register_map do
    property :reference, forward_to: :lookup_reference, verify: :all
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
      error_condition { reference? && !lookup_reference }
      message { "no such bit field found: #{@input_reference}" }
    end

    verify(:all) do
      error_condition { reference? && lookup_reference.reserved? }
      message { "refer to reserved bit field: #{@input_reference}" }
    end

    private

    def lookup_reference
      return unless reference?
      @lookup_reference ||=
        register_block.bit_fields
          .find { |bit_field| bit_field.full_name == @input_reference }
    end
  end
end
