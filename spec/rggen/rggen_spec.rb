# frozen_string_literal: true

RSpec.describe RgGen do
  let(:cli) { RgGen::Core::CLI.new }

  let(:configuration) do
    file = ['config.yml', 'config.json'].sample
    File.join(RGGEN_SAMPLE_DIRECTORY, file)
  end

  let(:block_0) do
    file = ['block_0.rb', 'block_0.yml', 'block_0.toml', 'block_0.xlsx'].sample
    File.join(RGGEN_SAMPLE_DIRECTORY, file)
  end

  let(:block_1) do
    file = ['block_1.rb', 'block_1.toml', 'block_1.yml'].sample
    File.join(RGGEN_SAMPLE_DIRECTORY, file)
  end

  let(:expectations) do
    [
      'block_0.sv',
      'block_1.sv',
      'block_0_ral_pkg.sv',
      'block_1_ral_pkg.sv',
      'block_0.md',
      'block_1.md',
      'block_0.v',
      'block_1.v',
      'block_0.vhd',
      'block_1.vhd'
    ].map { |file| ["./#{file}", read_sample(file)] }.to_h
  end

  def read_sample(file)
    File.binread(File.join(RGGEN_SAMPLE_DIRECTORY, file))
  end

  it 'コンフィグレーション/レジスタマップを読み込み、RTL/RAL/Markdownを書き出す' do
    actual = {}
    allow(File).to receive(:binwrite) do |path, content|
      actual[path.to_s] = content.to_s
    end

    cli.run([
      '-c', configuration,
      '--plugin', 'rggen-verilog',
      '--plugin', 'rggen-vhdl',
      block_0, block_1
    ])
    actual.each do |path, content|
      expect(content).to eq expectations[path]
    end
  end
end
