# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in rggen.gemspec
gemspec

[
  'rggen-devtools',
  'rggen-core',
  'rggen-default-register-map',
  'rggen-markdown',
  'rggen-spreadsheet-loader',
  'rggen-systemverilog'
].each do |rggen_library|
  library_path = File.expand_path("../#{rggen_library}", __dir__)
  if Dir.exist?(library_path) && !ENV['USE_GITHUB_REPOSITORY']
    gem rggen_library, path: library_path
  else
    gem rggen_library, git: "https://github.com/rggen/#{rggen_library}.git"
  end
end

if ENV['USE_FIXED_GEMS']
  ['facets', 'rubyzip'].each do |library|
    library_path = File.expand_path("../#{library}", __dir__)
    if Dir.exist?(library_path) && !ENV['USE_GITHUB_REPOSITORY']
      gem library, path: library_path
    else
      gem library, git: "https://github.com/taichi-ishitani/#{library}.git"
    end
  end

  gem 'ruby-ole', '>= 1.2.12.2'
  gem 'spreadsheet', '>= 1.2.1'
end

group :develop do
  gem 'rake'
  gem 'rubocop', '>= 0.48.0', require: false
end

group :test do
  gem 'codecov', require: false
  gem 'regexp-examples', RUBY_VERSION >= '2.4.0' ? '~> 1.5.1' : '< 1.5.0', require: false
  gem 'rspec', '>= 3.8'
  gem 'simplecov', '~> 0.17.0', require: false
end
