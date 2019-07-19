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

        def support_array_register
          @support_array_register = true
        end

        def support_array_register?
          @support_array_register || false
        end

        def byte_size(&block)
          @byte_size = block if block_given?
          @byte_size
        end

        def support_overlapped_address
          @support_overlapped_address = true
        end

        def support_overlapped_address?
          @support_overlapped_address || false
        end
      end

      property :type, body: -> { @type || :default }
      property :writable?, forward_to: :writability
      property :readable?, forward_to: :readability
      property :width, body: -> { @width ||= calc_width }
      property :byte_width, body: -> { @byte_width ||= width / 8 }
      property :array?, forward_to: :array_register?
      property :array_size, body: -> { (array? && register.size) || nil }
      property :count, body: -> { @count ||= calc_count }
      property :byte_size, body: -> { @byte_size ||= calc_byte_size }
      property :match_type?, body: ->(register) { register.type == type }
      property :support_overlapped_address?, forward_to_helper: true

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

      def calc_width
        bus_width = configuration.bus_width
        if helper.need_bit_fields?
          ((collect_msb.max + bus_width) / bus_width) * bus_width
        else
          bus_width
        end
      end

      def collect_msb
        register.bit_fields.collect do |bit_field|
          bit_field.msb((bit_field.sequence_size || 1) - 1)
        end
      end

      def array_register?
        helper.support_array_register? && !register.size.nil?
      end

      def calc_count
        Array(array_size).reduce(1, :*)
      end

      def calc_byte_size
        if helper.byte_size
          instance_exec(&helper.byte_size)
        else
          Array(register.size).reduce(1, :*) * byte_width
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

      def address_width
        register_block.local_address_width
      end

      def offset_address
        hex(register.offset_address, address_width)
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
        access =
          if register.writable? && register.readable?
            'RW'
          elsif register.writable?
            'WO'
          else
            'RO'
          end
        string(access)
      end

      def unmapped
        helper.unmapped? && 1 || 0
      end

      def hdl_path(array_index)
        string([
          "g_#{register.name}",
          *Array(array_index).map { |i| "g[#{i}]" },
          'u_register'
        ].join('.'))
      end

      def variables
        register.declarations(:register, :variable)
      end

      def field_model_constructors
        register.bit_fields.flat_map(&:constructors)
      end
    end

    default_feature do
      template_path = File.join(__dir__, 'type', 'default_sv_ral.erb')
      main_code :ral_package, from_template: template_path
    end

    factory do
      def select_feature(_configuration, register)
        target_features[register.type]
      end
    end
  end
end
