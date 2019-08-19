# frozen_string_literal: true

RgGen.define_simple_feature(:register_block, :markdown) do
  markdown do
    export def anchor_id
      register_block.name
    end
  end
end
