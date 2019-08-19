# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :markdown) do
  markdown do
    export def anchor_id
      [register.anchor_id, bit_field.name].join('-')
    end
  end
end
