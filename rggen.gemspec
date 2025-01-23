# frozen_string_literal: true

require File.expand_path('lib/rggen/version', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'rggen'
  spec.version = RgGen::VERSION
  spec.authors = ['Taichi Ishitani']
  spec.email = ['rggen@googlegroups.com']

  spec.summary = 'Code generation tool for control and status registers'
  spec.description = <<~DESCRIPTION
    RgGen is a code generation tool for ASIC/IP/FPGA/RTL engineers.
    It will automatically generate source code related to control and status registers (CSR),
    e.g. SytemVerilog RTL, UVM RAL model, C header file, Wiki documents, from human readable register map specifications.
  DESCRIPTION
  spec.homepage = 'https://github.com/rggen/rggen'
  spec.license = 'MIT'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/rggen/rggen/issues',
    'mailing_list_uri' => 'https://groups.google.com/d/forum/rggen',
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/rggen/rggen',
    'wiki_uri' => 'https://github.com/rggen/rggen/wiki'
  }

  spec.files =
    `git ls-files lib logo LICENSE CODE_OF_CONDUCT.md CONTRIBUTING.md README.md`
      .split($RS)
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('>= 3.1')

  spec.add_runtime_dependency 'rggen-c-header', '~> 0.6.0'
  spec.add_runtime_dependency 'rggen-core', '~> 0.34.0'
  spec.add_runtime_dependency 'rggen-default-register-map', '~> 0.34.0'
  spec.add_runtime_dependency 'rggen-markdown', '~> 0.27.0'
  spec.add_runtime_dependency 'rggen-spreadsheet-loader', '~> 0.26.0'
  spec.add_runtime_dependency 'rggen-systemverilog', '~> 0.34.0'
end
