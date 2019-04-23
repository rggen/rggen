# frozen_string_literal: true

RgGen.define_simple_feature(:register, :name) do
  register_map do
    property :name

    ignore_empty_value false
    input_pattern /(?<name>#{variable_name})/

    build do |value|
      @name =
        if pattern_matched?
          match_data[:name]
        else
          error "illegal input value for register name: #{value.inspect}"
        end
    end

    verify do
      error "duplicated register name: #{name}" if duplicated_name?
    end

    private

    def duplicated_name?
      register_block.registers.any? { |register| register.name == name }
    end
  end
end
