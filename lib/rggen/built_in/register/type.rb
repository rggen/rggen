# frozen_string_literal: true

RgGen.define_list_feature(:register, :type) do
  register_map do
    base_feature do
      define_helpers do
        def writable?(&block)
          @writability = block
        end

        def readable?(&block)
          @readability = block
        end

        attr_reader :writability
        attr_reader :readability

        def no_bit_fields
          @no_bit_fields = true
        end

        def need_bit_fields?
          !@no_bit_fields
        end

        def settings
          @settings ||= {}
        end

        def support_array_register
          settings[:support_array] = true
        end

        def byte_size(&block)
          settings[:byte_size] = block
        end

        def support_overlapped_address
          settings[:support_overlapped_address] = true
        end
      end

      property :type, default: :default
      property :match_type?, body: ->(register) { register.type == type }
      property :writable?, forward_to: :writability
      property :readable?, forward_to: :readability
      property :settings, forward_to_helper: true

      build do |value|
        @type = value[:type]
        @options = value[:options]
        helper.need_bit_fields? || register.need_no_children
      end

      verify(:component) do
        error_condition do
          helper.need_bit_fields? && register.bit_fields.empty?
        end
        message { 'no bit fields are given' }
      end

      private

      attr_reader :options

      def writability
        if @writability.nil?
          block = helper.writability || default_writability
          @writability = instance_exec(&block)
        end
        @writability
      end

      def default_writability
        -> { register.bit_fields.any?(&:writable?) }
      end

      def readability
        if @readability.nil?
          block = helper.readability || default_readability
          @readability = instance_exec(&block)
        end
        @readability
      end

      def default_readability
        lambda do
          block = ->(bit_field) { bit_field.readable? || bit_field.reserved? }
          register.bit_fields.any?(&block)
        end
      end
    end

    default_feature do
      support_array_register

      verify(:feature) do
        error_condition { @type }
        message { "unknown register type: #{@type.inspect}" }
      end
    end

    factory do
      convert_value do |value|
        type, options = split_input_value(value)
        { type: find_type(type), options: Array(options) }
      end

      def select_feature(cell)
        if cell.empty_value?
          target_feature
        else
          target_features[cell.value[:type]]
        end
      end

      private

      def split_input_value(value)
        if value.is_a?(String)
          split_string_value(value)
        else
          input_value = Array(value)
          [input_value[0], input_value[1..-1]]
        end
      end

      def split_string_value(value)
        type, options = split_string(value, ':', 2)
        [type, split_string(options, /[,\n]/, 0)]
      end

      def split_string(value, separator, limit)
        value&.split(separator, limit)&.map(&:strip)
      end

      def find_type(type)
        types = target_features.keys
        types.find(&type.to_sym.method(:casecmp?)) || type
      end
    end
  end

  sv_rtl do
    base_feature do
      private

      def readable
        register.readable? && 1 || 0
      end

      def writable
        register.writable? && 1 || 0
      end

      def bus_width
        configuration.bus_width
      end

      def address_width
        register_block.local_address_width
      end

      def offset_address
        hex(register.offset_address, address_width)
      end

      def width
        register.width
      end

      def valid_bits
        bits = register.bit_fields.map(&:bit_map).inject(:|)
        hex(bits, register.width)
      end

      def register_index
        register.local_index || 0
      end

      def register_if
        register_block.register_if[register.index]
      end

      def bit_field_if
        register.bit_field_if
      end
    end

    default_feature do
      template_path = File.join(__dir__, 'type', 'default_sv_rtl.erb')
      main_code :register, from_template: template_path
    end

    factory do
      def select_feature(_configuration, register)
        target_features[register.type]
      end
    end
  end

  sv_ral do
    base_feature do
      define_helpers do
        def model_name(&body)
          @model_name = body if block_given?
          @model_name
        end

        def offset_address(&body)
          @offset_address = body if block_given?
          @offset_address
        end

        def unmapped
          @unmapped = true
        end

        def unmapped?
          !@unmapped.nil?
        end

        def constructor(&body)
          @constructor = body if block_given?
          @constructor
        end
      end

      export :constructors

      build do
        variable :register_block, :ral_model, {
          name: register.name,
          data_type: model_name,
          array_size: register.array_size,
          random: true
        }
      end

      def constructors
        (array_index_list || [nil]).map.with_index do |array_index, i|
          constructor_code(array_index, i)
        end
      end

      private

      def model_name
        if helper.model_name
          instance_eval(&helper.model_name)
        else
          "#{register.name}_reg_model"
        end
      end

      def array_index_list
        (register.array? || nil) &&
          begin
            index_table = register.array_size.map { |size| (0...size).to_a }
            index_table[0].product(*index_table[1..-1])
          end
      end

      def constructor_code(array_index, index)
        if helper.constructor
          instance_exec(array_index, index, &helper.constructor)
        else
          macro_call(
            :rggen_ral_create_reg_model, arguments(array_index, index)
          )
        end
      end

      def arguments(array_index, index)
        [
          ral_model[array_index], array(array_index), offset_address(index),
          access_rights, unmapped, hdl_path(array_index)
        ]
      end

      def offset_address(index = 0)
        address =
          if helper.offset_address
            instance_exec(index, &helper.offset_address)
          else
            register.offset_address + register.byte_width * index
          end
        hex(address, register_block.local_address_width)
      end

      def access_rights
        if register.writable? && register.readable?
          'RW'
        elsif register.writable?
          'WO'
        else
          'RO'
        end
      end

      def unmapped
        helper.unmapped? && 1 || 0
      end

      def hdl_path(array_index)
        [
          "g_#{register.name}",
          *Array(array_index).map { |i| "g[#{i}]" },
          'u_register'
        ].join('.')
      end

      def variables
        register.declarations(:register, :variable)
      end

      def field_model_constructors
        register.bit_fields.flat_map(&:constructors)
      end
    end

    default_feature do
      main_code :ral_package do
        class_definition(model_name) do |sv_class|
          sv_class.base 'rggen_ral_reg'
          sv_class.variables variables
          sv_class.body { model_body }
        end
      end

      private

      def model_body
        process_template(File.join(__dir__, 'type', 'default_sv_ral.erb'))
      end
    end

    factory do
      def select_feature(_configuration, register)
        target_features[register.type]
      end
    end
  end
end
