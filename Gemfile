# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in rggen.gemspec
gemspec

[
  'rggen-devtools', 'rggen-core', 'rggen-systemverilog', 'rggen-spreadsheet-loader'
].each do |rggen_library|
  library_path = File.expand_path("../#{rggen_library}", __dir__)
  if Dir.exist?(library_path) && !ENV['USE_GITHUB_REPOSITORY']
    gem rggen_library, path: library_path
  else
    gem rggen_library, git: "https://github.com/rggen/#{rggen_library}.git"
  end
end

group :develop do
  gem 'rake'
  gem 'rubocop', '>= 0.48.0', require: false
end

group :test do
  gem 'codecov', require: false
  gem 'regexp-examples', require: false
  gem 'rspec', '>= 3.8'
  gem 'simplecov', require: false
end
