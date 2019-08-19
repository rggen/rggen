# frozen_string_literal: true

RSpec.describe 'register/markdown' do
  include_context 'clean-up builder'
  include_context 'markdown common'

  before(:all) do
    RgGen.enable(:register_block, [:name, :markdown])
    RgGen.enable(:register, [:name, :markdown])
  end

  describe '#anchor_id' do
    let(:markdown) do
      md = create_markdown do
        name 'register_block'
        register { name 'register' }
      end
      md.registers.first
    end

    it 'アンカー用IDとして、自身の#nameと上位階層の#anchor_idを連接したものを返す' do
      expect(markdown.anchor_id).to eq 'register_block-register'
    end
  end
end
