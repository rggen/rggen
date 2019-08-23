# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :name) do
  register_map do
    property :name, body: -> { @name ||= register.name }
    property :full_name, forward_to: :get_full_name

    input_pattern variable_name

    build do |value|
      @name =
        if pattern_matched?
          match_data.to_s
        else
          error "illegal input value for bit field name: #{value.inspect}"
        end
      @full_name = [register.name, @name]
    end

    verify(:feature) do
      error_condition { duplicated_name? }
      message { "duplicated bit field name: #{name}" }
    end

    printable :name

    private

    def get_full_name(separator = '.')
      @full_name&.join(separator) || register.name
    end

    def duplicated_name?
      register.bit_fields.any? { |bit_field| bit_field.name == name }
    end
  end
end
