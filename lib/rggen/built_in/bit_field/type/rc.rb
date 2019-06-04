# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :rc) do
  register_map do
    read_only
    use_reference
    need_initial_value
  end
end
