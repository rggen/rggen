# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :rof) do
  register_map do
    read_only
    non_volatile
    need_initial_value
  end

  sv_rtl do
    main_code :bit_field, from_template: true
  end

  sv_ral do
    access 'RO'
  end
end
