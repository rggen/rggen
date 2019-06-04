# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, [:rwe, :rwl]) do
  register_map do
    read_write
    need_initial_value
    use_reference required: true, width: 1
  end
end
