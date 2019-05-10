# frozen_string_literal: true

RgGen.define_simple_feature(:register_block, :name) do
  register_map do
    property :name

    ignore_empty_value false
    input_pattern /(?<name>#{variable_name})/

    build do |value|
      @name =
        if pattern_matched?
          match_data[:name]
        else
          error "illegal input value for register block name: #{value.inspect}"
        end
    end

    verify(:feature) do
      error_condition { duplicated_name? }
      message { "duplicated register block name: #{name}" }
    end

    private

    def duplicated_name?
      register_map
        .register_blocks
        .any? { |register_block| register_block.name == name }
    end
  end
end
