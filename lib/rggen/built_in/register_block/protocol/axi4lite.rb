# frozen_string_literal: true

RgGen.define_list_item_feature(:register_block, :protocol, :axi4lite) do
  configuration do
    verify(:component) do
      error_condition { ![32, 64].include?(configuration.bus_width) }
      message do
        'bus width eigher 32 bit or 64 bit is only supported: ' \
        "#{configuration.bus_width}"
      end
    end
  end

  sv_rtl {}
end
