# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :reserved) do
  register_map do
    reserved
  end

  sv_rtl do
    main_code :bit_field, from_template: true
  end

  sv_ral do
    access 'RO'
  end
end
