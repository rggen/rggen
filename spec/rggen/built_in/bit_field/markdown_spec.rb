# frozen_string_literal: true

RSpec.describe 'bit_field/markdown' do
  include_context 'clean-up builder'
  include_context 'markdown common'

  before(:all) do
    RgGen.enable(:register_block, [:name, :markdown])
    RgGen.enable(:register, [:name, :markdown])
    RgGen.enable(:bit_field, [:name, :markdown])
  end

  describe '#anchor_id' do
    let(:markdown) do
      md = create_markdown do
        name 'register_block'
        register do
          name 'register'
          bit_field { name 'bit_field' }
        end
      end
      md.bit_fields.first
    end

    it 'アンカー用IDとして、自身の#nameと上位階層の#anchor_idを連接したものを返す' do
      expect(markdown.anchor_id).to eq 'register_block-register-bit_field'
    end
  end
end
