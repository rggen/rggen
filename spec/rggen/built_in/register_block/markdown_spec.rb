# frozen_string_literal: true

RSpec.describe 'register_block/markdown' do
  include_context 'clean-up builder'
  include_context 'markdown common'

  before(:all) do
    RgGen.enable(:register_block, :markdown)
    RgGen.enable(:register, :markdown)
  end

  describe '#anchor_id' do
    before(:all) do
      delete_configuration_factory
      delete_register_map_factory
    end

    before(:all) do
      RgGen.enable(:register_block, :name)
    end

    after(:all) do
      RgGen.disable(:register_block, :name)
    end

    let(:markdown) do
      create_markdown { name 'foo' }.register_blocks.first
    end

    it 'アンカー用IDとして、#nameを返す' do
      expect(markdown.anchor_id).to eq 'foo'
    end
  end

  describe '#write_file' do
    before(:all) do
      delete_configuration_factory
      delete_register_map_factory
    end

    before(:all) do
      RgGen.enable(:global, [:bus_width, :address_width])
      RgGen.enable(:register_block, [:name, :byte_size, :protocol])
      RgGen.enable(:register_block, :protocol, :apb)
      RgGen.enable(:register, [:name, :offset_address, :size, :type])
      RgGen.enable(:register, :type, [:external, :indirect])
      RgGen.enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference, :comment])
      RgGen.enable(:bit_field, :type, [:rc, :reserved, :ro, :rof, :rs, :rw, :rwc, :rwe, :rwl, :w0c, :w1c, :w0s, :w1s, :w0trg, :w1trg, :wo])
    end

    after(:all) do
      RgGen.disable(:global, [:bus_width, :address_width])
      RgGen.disable(:register_block, [:name, :byte_size, :protocol])
      RgGen.disable(:register_block, :protocol, :apb)
      RgGen.disable(:register, [:name, :offset_address, :size, :type])
      RgGen.disable(:register, :type, [:external, :indirect])
      RgGen.disable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference, :comment])
      RgGen.disable(:bit_field, :type, [:rc, :reserved, :ro, :rof, :rs, :rw, :rwc, :rwe, :rwl, :w0c, :w1c, :w0s, :w1s, :w0trg, :w1trg, :wo])
    end

    before do
      allow(FileUtils).to receive(:mkpath)
    end

    let(:configuration) do
      file = ['config.yml', 'config.json'].sample
      path = File.join(RGGEN_ROOT, 'sample', file)
      build_configuration_factory(RgGen.builder, false).create([path])
    end

    let(:register_map) do
      file = ['block_0.rb', 'block_0.xlsx', 'block_0.yml'].sample
      path = File.join(RGGEN_ROOT, 'sample', file)
      build_register_map_factory(RgGen.builder, false).create(configuration, [path])
    end

    let(:markdown) do
      build_markdown_factory(RgGen.builder)
        .create(configuration, register_map).register_blocks.first
    end

    let(:expected_code) do
      path = File.join(RGGEN_ROOT, 'sample', 'block_0.md')
      File.binread(path)
    end

    it 'Markdownを書き出す' do
      expect {
        markdown.write_file('foo')
      }.to write_file(match_string('foo/block_0.md'), expected_code)
    end
  end
end
