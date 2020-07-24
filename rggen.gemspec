# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.include?(lib) || $LOAD_PATH.unshift(lib)
require 'rggen/version'

Gem::Specification.new do |spec|
  spec.name = 'rggen'
  spec.version = RgGen::VERSION
  spec.authors = ['Taichi Ishitani']
  spec.email = ['rggen@googlegroups.com']

  spec.summary = 'Code generation tool for configuration and status registers'
  spec.description = <<~'DESCRIPTION'
    RgGen is a code generation tool for ASIC/IP/FPGA/RTL engineers.
    It will automatically generate soruce code related to configuration and status registers (CSR),
    e.g. SytemVerilog RTL, UVM RAL model, Wiki documents, from human readable register map specifications.
  DESCRIPTION
  spec.homepage = 'https://github.com/rggen/rggen'
  spec.license = 'MIT'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/rggen/rggen/issues',
    'mailing_list_uri' => 'https://groups.google.com/d/forum/rggen',
    'source_code_uri' => 'https://github.com/rggen/rggen',
    'wiki_uri' => 'https://github.com/rggen/rggen/wiki'
  }

  spec.files =
    `git ls-files lib LICENSE CODE_OF_CONDUCT.md README.md`.split($RS)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'

  spec.add_runtime_dependency 'rggen-core', '~> 0.21.0'
  spec.add_runtime_dependency 'rggen-default-register-map', '~> 0.21.0'
  spec.add_runtime_dependency 'rggen-markdown', '~> 0.18.0'
  spec.add_runtime_dependency 'rggen-spreadsheet-loader', '~> 0.17.0'
  spec.add_runtime_dependency 'rggen-systemverilog', '~> 0.21.1'

  spec.add_development_dependency 'bundler'
end
