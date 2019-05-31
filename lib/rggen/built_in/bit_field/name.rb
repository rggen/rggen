# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :name) do
  register_map do
    property :name
    property :full_name, forward_to: :get_full_name

    input_pattern variable_name

    build do |value|
      @name =
        if pattern_matched?
          match_data.to_s
        else
          error "illegal input value for bit field name: #{value.inspect}"
        end
    end

    verify(:feature) do
      error_condition { !name }
      message { 'no bit field name is given' }
    end

    verify(:feature) do
      error_condition { duplicated_name? }
      message { "duplicated bit field name: #{name}" }
    end

    private

    def get_full_name(separator = '.')
      [register.name, name].join(separator)
    end

    def duplicated_name?
      register.bit_fields.any? { |bit_field| bit_field.name == name }
    end
  end
end
