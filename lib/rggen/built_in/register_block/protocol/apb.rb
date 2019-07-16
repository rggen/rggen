# frozen_string_literal: true

RgGen.define_list_item_feature(:register_block, :protocol, :apb) do
  configuration do
    verify(:component) do
      error_condition { configuration.bus_width > 32 }
      message do
        'bus width over 32 bit is not supported: ' \
        "#{configuration.bus_width}"
      end
    end

    verify(:component) do
      error_condition { configuration.address_width > 32 }
      message do
        'address width over 32 bit is not supported: ' \
        "#{configuration.address_width}"
      end
    end
  end

  sv_rtl do
    build do
      if configuration.fold_sv_interface_port?
        interface_port :register_block, :apb_if, {
          name: 'apb_if',
          interface_type: 'rggen_apb_if',
          modport: 'slave'
        }
      else
        input :register_block, :psel, {
          name: 'i_psel',
          data_type: :logic,
          width: 1
        }
        input :register_block, :penable, {
          name: 'i_penable',
          data_type: :logic,
          width: 1
        }
        input :register_block, :paddr, {
          name: 'i_paddr',
          data_type: :logic,
          width: configuration.address_width
        }
        input :register_block, :pprot, {
          name: 'i_pprot',
          data_type: :logic,
          width: 3
        }
        input :register_block, :pwrite, {
          name: 'i_pwrite',
          data_type: :logic,
          width: 1
        }
        input :register_block, :pstrb, {
          name: 'i_pstrb',
          data_type: :logic,
          width: configuration.byte_width
        }
        input :register_block, :pwdata, {
          name: 'i_pwdata',
          data_type: :logic,
          width: configuration.bus_width
        }
        output :register_block, :pready, {
          name: 'o_pready',
          data_type: :logic,
          width: 1
        }
        output :register_block, :prdata, {
          name: 'o_prdata',
          data_type: :logic,
          width: configuration.bus_width
        }
        output :register_block, :pslverr, {
          name: 'o_pslverr',
          data_type: :logic,
          width: 1
        }
        interface :register_block, :apb_if, {
          name: 'apb_if',
          interface_type: 'rggen_apb_if',
          parameter_values: [
            configuration.address_width, configuration.bus_width
          ],
          variables: [
            'psel', 'penable', 'paddr', 'pprot', 'pwrite', 'pstrb', 'pwdata',
            'pready', 'prdata', 'pslverr'
          ]
        }
      end
    end

    main_code :register_block do |code|
      code << process_template
      apb_if_connections(code) unless configuration.fold_sv_interface_port?
    end

    private

    def apb_if_connections(code)
      code << assign(apb_if.psel, psel) << nl
      code << assign(apb_if.penable, penable) << nl
      code << assign(apb_if.paddr, paddr) << nl
      code << assign(apb_if.pprot, pprot) << nl
      code << assign(apb_if.pwrite, pwrite) << nl
      code << assign(apb_if.pstrb, pstrb) << nl
      code << assign(apb_if.pwdata, pwdata) << nl
      code << assign(pready, apb_if.pready) << nl
      code << assign(prdata, apb_if.prdata) << nl
      code << assign(pslverr, apb_if.pslverr) << nl
    end
  end
end
