# frozen_string_literal: true

RgGen.define_simple_feature(:register, :markdown) do
  markdown do
    export def anchor_id
      [register_block.anchor_id, register.name].join('-')
    end
  end
end
