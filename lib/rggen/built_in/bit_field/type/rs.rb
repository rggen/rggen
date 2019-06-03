# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :rs) do
  register_map do
    read_only
    need_initial_value
  end
end
