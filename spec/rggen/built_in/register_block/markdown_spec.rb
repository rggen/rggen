# frozen_string_literal: true

RSpec.describe 'register_block/markdown' do
  include_context 'clean-up builder'
  include_context 'markdown common'

  before(:all) do
    RgGen.enable(:register_block, [:name, :markdown])
  end

  describe '#anchor_id' do
    let(:markdown) do
      create_markdown { name 'foo' }.register_blocks.first
    end

    it 'アンカー用IDとして、#nameを返す' do
      expect(markdown.anchor_id).to eq 'foo'
    end
  end
end
