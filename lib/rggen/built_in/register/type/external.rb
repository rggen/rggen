# frozen_string_literal: true

RgGen.define_list_item_feature(:register, :type, :external) do
  register_map do
    writable? { true }
    readable? { true }
    no_bit_fields

    verify(:component) do
      error_condition { register.size && register.size.length > 1 }
      message do
        'external register type supports single size definition only'
      end
    end
  end

  sv_rtl do
    build do
      if configuration.fold_sv_interface_port?
        interface_port :register_block, :bus_if, {
          name: "#{register.name}_bus_if",
          interface_type: 'rggen_bus_if',
          modport: 'master'
        }
      else
        output :register_block, :valid, {
          name: "o_#{register.name}_valid",
          data_type: :logic,
          width: 1
        }
        output :register_block, :address, {
          name: "o_#{register.name}_address",
          data_type: :logic,
          width: address_width
        }
        output :register_block, :write, {
          name: "o_#{register.name}_write",
          data_type: :logic,
          width: 1
        }
        output :register_block, :write_data, {
          name: "o_#{register.name}_data",
          data_type: :logic,
          width: bus_width
        }
        output :register_block, :strobe, {
          name: "o_#{register.name}_strobe",
          data_type: :logic,
          width: byte_width
        }
        input :register_block, :ready, {
          name: "i_#{register.name}_ready",
          data_type: :logic,
          width: 1
        }
        input :register_block, :status, {
          name: "i_#{register.name}_status",
          data_type: :logic,
          width: 2
        }
        input :register_block, :read_data, {
          name: "i_#{register.name}_data",
          data_type: :logic,
          width: bus_width
        }
        interface :register, :bus_if, {
          name: 'bus_if',
          interface_type: 'rggen_bus_if',
          parameter_values: [address_width, bus_width],
          variables: [
            'valid', 'address', 'write', 'write_data', 'strobe',
            'ready', 'status', 'read_data'
          ]
        }
      end
    end

    main_code :register do |code|
      code << process_template
      bus_if_connections(code) unless configuration.fold_sv_interface_port?
    end

    private

    def address_width
      register_block.local_address_width
    end

    def bus_width
      configuration.bus_width
    end

    def byte_width
      configuration.byte_width
    end

    def start_address
      hex(register.offset_address, address_width)
    end

    def end_address
      address = register.offset_address + register.byte_size - 1
      hex(address, address_width)
    end

    def bus_if_connections(code)
      code << assign(valid, bus_if.valid) << nl
      code << assign(address, bus_if.address) << nl
      code << assign(write, bus_if.write) << nl
      code << assign(write_data, bus_if.write_data) << nl
      code << assign(strobe, bus_if.strobe) << nl
      code << assign(bus_if.ready, ready) << nl
      code << assign(bus_if.status, "rggen_status'(#{status})") << nl
      code << assign(bus_if.read_data, read_data) << nl
    end
  end
end
