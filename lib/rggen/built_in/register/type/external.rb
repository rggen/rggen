# frozen_string_literal: true

RgGen.define_list_item_feature(:register, :type, :external) do
  register_map do
    writable? { true }
    readable? { true }
    no_bit_fields

    verify(:component) do
      error_condition { register.size && register.size.length > 1 }
      message do
        'external register type supports single size definition only'
      end
    end
  end
end
