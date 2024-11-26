# frozen_string_literal: true

RSpec.describe RgGen do
  let(:cli) { RgGen::Core::CLI.new }

  let(:configuration) do
    file = ['config.yml', 'config.json'].sample
    File.join(RGGEN_SAMPLE_DIRECTORY, file)
  end

  let(:block_0) do
    file = ['block_0.rb', 'block_0.yml', 'block_0.toml', 'block_0.xlsx', 'block_0.ods'].sample
    File.join(RGGEN_SAMPLE_DIRECTORY, file)
  end

  let(:block_1) do
    file = ['block_1.rb', 'block_1.toml', 'block_1.yml'].sample
    File.join(RGGEN_SAMPLE_DIRECTORY, file)
  end

  let(:uart_csr) do
    file = ['uart_csr.rb', 'uart_csr.yml'].sample
    File.join(RGGEN_SAMPLE_DIRECTORY, file)
  end

  let(:expectations) do
    [
      'block_0.sv',
      'block_1.sv',
      'uart_csr.sv',
      'block_0_rtl_pkg.sv',
      'block_1_rtl_pkg.sv',
      'uart_csr_rtl_pkg.sv',
      'block_0_ral_pkg.sv',
      'block_1_ral_pkg.sv',
      'uart_csr_ral_pkg.sv',
      'block_0.h',
      'block_1.h',
      'uart_csr.h',
      'block_0.md',
      'block_1.md',
      'uart_csr.md',
      'block_0.v',
      'block_1.v',
      'uart_csr.v',
      'block_0.vh',
      'block_1.vh',
      'uart_csr.vh',
      'block_0.vhd',
      'block_1.vhd',
      'uart_csr.vhd',
      'block_0.veryl',
      'block_1.veryl',
      'uart_csr.veryl',
    ].map { |file| ["./#{file}", read_sample(file)] }.to_h
  end

  def read_sample(file)
    File.binread(File.join(RGGEN_SAMPLE_DIRECTORY, file))
  end

  it 'コンフィグレーション/レジスタマップを読み込み、RTL/RAL/C Header/Markdownを書き出す' do
    actual = {}
    allow(File).to receive(:binwrite) do |path, content|
      actual[path.to_s] = content.to_s
    end

    cli.run([
      '-c', configuration,
      '--plugin', 'rggen-verilog',
      '--plugin', 'rggen-vhdl',
      '--plugin', 'rggen-veryl',
      block_0, block_1, uart_csr
    ])
    actual.each do |path, content|
      expect(content).to eq expectations[path]
    end
  end
end
