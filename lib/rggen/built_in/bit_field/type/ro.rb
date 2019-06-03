# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :ro) do
  register_map do
    read_only
    use_reference
  end
end
