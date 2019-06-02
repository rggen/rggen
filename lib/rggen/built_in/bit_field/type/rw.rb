# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :rw) do
  register_map do
    read_write
    need_initial_value
  end
end
