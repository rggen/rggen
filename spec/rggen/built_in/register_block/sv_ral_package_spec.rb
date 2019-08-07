# frozen_string_literal: true

RSpec.describe 'register_block/sv_ral_package' do
  include_context 'sv ral common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, [:bus_width, :address_width])
    RgGen.enable(:register_block, [:name, :byte_size])
    RgGen.enable(:register, [:name, :offset_address, :size, :type])
    RgGen.enable(:register, :type, [:external, :indirect])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
    RgGen.enable(:bit_field, :type, [:rc, :reserved, :ro, :rof, :rs, :rw, :rwc, :rwe, :rwl, :w0c, :w1c, :w0s, :w1s, :w0trg, :w1trg, :wo])
    RgGen.enable(:register_block, :sv_ral_package)
  end

  describe '#write_file' do
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

    let(:sv_ral) do
      build_sv_ral_factory(RgGen.builder).create(configuration, register_map).register_blocks[0]
    end

    let(:expected_code) do
      path = File.join(RGGEN_ROOT, 'sample', 'block_0_ral_pkg.sv')
      File.binread(path)
    end

    it 'RALモデルを格納したパッケージを書き出す' do
      expect {
        sv_ral.write_file('foo')
      }.to write_file match_string('foo/block_0_ral_pkg.sv'), expected_code
    end
  end
end
