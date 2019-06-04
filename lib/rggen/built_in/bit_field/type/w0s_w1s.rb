# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, [:w0s, :w1s]) do
  register_map do
    read_write
    need_initial_value
  end
end
