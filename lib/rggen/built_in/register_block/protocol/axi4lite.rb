# frozen_string_literal: true

RgGen.define_list_item_feature(:register_block, :protocol, :axi4lite) do
  configuration do
    verify(:component) do
      error_condition { ![32, 64].include?(configuration.data_width) }
      message do
        'data width eigher 32 bit or 64 bit is only supported: ' \
        "#{configuration.data_width}"
      end
    end
  end

  sv_rtl {}
end
