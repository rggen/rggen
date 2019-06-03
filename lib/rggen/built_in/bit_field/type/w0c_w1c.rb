# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, [:w0c, :w1c]) do
  register_map do
    read_write
    use_reference
    need_initial_value
  end
end
