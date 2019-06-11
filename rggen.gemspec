# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.include?(lib) || $LOAD_PATH.unshift(lib)
require 'rggen/version'

Gem::Specification.new do |spec|
  spec.name = 'rggen'
  spec.version = RgGen::VERSION
  spec.authors = ['Taichi Ishitani']
  spec.email = ['taichi730@gmail.com']

  spec.summary = 'Code generation tool for control/status regiters'
  spec.description = <<~'EOS'
    RgGen is a code generator tool for SoC/IP/FPGA/RTL engineers.
    It will automatically generate source files for control/status registers, e.g. RTL, UVM RAL model, from its register map document.
    Also RgGen is customizable so you can build your specific generate tool.
  EOS
  spec.homepage = 'https://github.com/rggen/rggen'
  spec.license = 'MIT'

  spec.files = `git ls-files lib sample LICENSE.txt CODE_OF_CONDUCT.md README.md`.split($RS)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_runtime_dependency 'rggen-core', '~> 0.1'
  spec.add_runtime_dependency 'rggen-spreadsheet-loader', '~> 0.1'
  spec.add_runtime_dependency 'rggen-systemverilog', '~> 0.1'

  spec.add_development_dependency 'bundler'
end
