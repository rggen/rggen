# frozen_string_literal: true

RgGen.define_list_item_feature(:register, :type, :indirect) do
  register_map do
    define_helpers do
      index_verifier = Class.new do
        def initialize(&block)
          instance_eval(&block)
        end

        def error_condition(&block)
          @error_condition = block
        end

        def message(&block)
          @message = block
        end

        def verify(feature, index)
          error?(feature, index) && raise_error(feature, index)
        end

        def error?(feature, index)
          feature.instance_exec(index, &@error_condition)
        end

        def raise_error(feature, index)
          error_message = feature.instance_exec(index, &@message)
          feature.__send__(:error, error_message)
        end
      end

      define_method(:verify_index) do |&block|
        index_verifiers << index_verifier.new(&block)
      end

      def index_verifiers
        @index_verifiers ||= []
      end
    end

    define_struct :index_entry, [:name, :value] do
      def value_index?
        !array_index?
      end

      def array_index?
        value.nil?
      end

      def distinguishable?(other)
        name == other.name && value != other.value &&
          [self, other].all?(&:value_index?)
      end

      def find_index_field(bit_fields)
        bit_fields.find { |bit_field| bit_field.full_name == name }
      end
    end

    property :index_entries
    property :collect_index_fields do |bit_fields|
      index_entries.map { |entry| entry.find_index_field(bit_fields) }
    end

    byte_size { byte_width }
    support_array_register
    support_overlapped_address

    input_pattern [
      /(#{variable_name}\.#{variable_name})/,
      /(#{variable_name}\.#{variable_name}):(#{integer})?/,
      /(#{variable_name})/,
      /(#{variable_name}):(#{integer})?/
    ], match_automatically: false

    build do
      @index_entries = parse_index_entries
    end

    verify(:component) do
      error_condition do
        register.array? &&
          register.array_size.length < array_index_fields.length
      end
      message { 'too many array indices are given' }
    end

    verify(:component) do
      error_condition do
        register.array? &&
          register.array_size.length > array_index_fields.length
      end
      message { 'less array indices are given' }
    end

    verify(:all) do
      check_error do
        index_entries.each(&method(:verify_indirect_index))
      end
    end

    verify_index do
      error_condition do |index|
        !index_entries.one? { |other| other.name == index.name }
      end
      message do |index|
        "same bit field is used as indirect index more than once: #{index.name}"
      end
    end

    verify_index do
      error_condition { |index| !index_field(index) }
      message do |index|
        "no such bit field for indirect index is found: #{index.name}"
      end
    end

    verify_index do
      error_condition do |index|
        index_field(index).register.name == register.name
      end
      message do |index|
        "own bit field is not allowed for indirect index: #{index.name}"
      end
    end

    verify_index do
      error_condition { |index| index_field(index).register.array? }
      message do |index|
        'bit field of array register is not allowed ' \
        "for indirect index: #{index.name}"
      end
    end

    verify_index do
      error_condition { |index| index_field(index).sequential? }
      message do |index|
        'sequential bit field is not allowed ' \
        "for indirect index: #{index.name}"
      end
    end

    verify_index do
      error_condition { |index| index_field(index).reserved? }
      message do |index|
        'reserved bit field is not allowed ' \
        "for indirect index: #{index.name}"
      end
    end

    verify_index do
      error_condition do |index|
        !index.array_index? &&
          (index.value > (2**index_field(index).width - 1))
      end
      message do |index|
        'bit width of indirect index is not enough for ' \
        "index value #{index.value}: #{index.name}"
      end
    end

    verify_index do
      error_condition do |index|
        index.array_index? &&
          (array_index_value(index) > 2**index_field(index).width)
      end
      message do |index|
        'bit width of indirect index is not enough for ' \
        "array size #{array_index_value(index)}: #{index.name}"
      end
    end

    verify(:all) do
      error_condition { !distinguishable? }
      message { 'cannot be distinguished from other registers' }
    end

    private

    def parse_index_entries
      (!options.empty? && options.map(&method(:create_index_entry))) ||
        (error 'no indirect indices are given')
    end

    def create_index_entry(value)
      input_values = split_value(value)
      if input_values.size == 2
        index_entry.new(input_values[0], convert_index_value(input_values[1]))
      elsif input_values.size == 1
        index_entry.new(input_values[0])
      else
        error 'too many arguments for indirect index ' \
              "are given: #{value.inspect}"
      end
    end

    def split_value(value)
      input_value = Array(value)
      field_name = input_value.first
      if sting_or_symbol?(field_name) && match_pattern(field_name)
        [*match_data.captures, *input_value[1..-1]]
      else
        error "illegal input value for indirect index: #{value.inspect}"
      end
    end

    def sting_or_symbol?(value)
      [String, Symbol].any?(&value.method(:is_a?))
    end

    def convert_index_value(value)
      Integer(value)
    rescue ArgumentError, TypeError
      error "cannot convert #{value.inspect} into indirect index value"
    end

    def verify_indirect_index(index)
      helper.index_verifiers.each { |verifier| verifier.verify(self, index) }
    end

    def index_field(index)
      @index_fields ||= {}
      @index_fields[index.name] ||=
        index.find_index_field(register_block.bit_fields)
    end

    def array_index_fields
      @array_index_fields ||= index_entries.select(&:array_index?)
    end

    def array_index_value(index)
      @array_index_values ||=
        array_index_fields
          .map.with_index { |entry, i| [entry.name, register.array_size[i]] }
          .to_h
      @array_index_values[index.name]
    end

    def distinguishable?
      register_block
        .registers.select { |other| share_same_range?(other) }
        .all? { |other| distinguishable_indices?(other.index_entries) }
    end

    def share_same_range?(other)
      register.name != other.name && register.overlap?(other)
    end

    def distinguishable_indices?(other_entries)
      index_entries.any? do |entry|
        other_entries.any?(&entry.method(:distinguishable?))
      end
    end
  end

  sv_rtl do
    build do
      logic :register, :indirect_index, { width: index_width }
    end

    main_code :register do |code|
      code << indirect_index_assignment << nl
      code << process_template(File.join(__dir__, 'indirect_sv_rtl.erb'))
    end

    private

    def index_fields
      @index_fields ||=
        register.collect_index_fields(register_block.bit_fields)
    end

    def index_width
      @index_width ||= index_fields.map(&:width).inject(:+)
    end

    def index_values
      loop_variables = register.loop_variables
      register.index_entries.zip(index_fields).map do |entry, field|
        if entry.array_index?
          loop_variables.shift[0, field.width]
        else
          hex(entry.value, field.width)
        end
      end
    end

    def indirect_index_assignment
      assign(indirect_index, concat(index_fields.map(&:value)))
    end
  end

  sv_ral do
    unmapped
    offset_address { register.offset_address }

    main_code :ral_package do
      class_definition(model_name) do |sv_class|
        sv_class.base 'rggen_ral_indirect_reg'
        sv_class.variables variables
        sv_class.body { model_body }
      end
    end

    private

    def model_body
      process_template(File.join(__dir__, 'indirect_sv_ral.erb'))
    end

    def index_properties
      array_position = -1
      register.index_entries.zip(index_fields).map do |entry, field|
        value =
          if entry.value_index?
            hex(entry.value, field.width)
          else
            "array_index[#{array_position += 1}]"
          end
        [field.register.name, field.name, value]
      end
    end

    def index_fields
      register.collect_index_fields(register_block.bit_fields)
    end
  end
end
