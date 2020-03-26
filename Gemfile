# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in rggen.gemspec
gemspec

group :rggen do
  rggen_root = ENV['RGGEN_ROOT'] || File.expand_path('..', __dir__)
  gemfile_path = File.join(rggen_root, 'rggen-checkout', 'Gemfile')
  File.exist?(gemfile_path) &&
    instance_eval(File.read(gemfile_path), gemfile_path, 1)

  if ENV['USE_FIXED_GEMS'] == 'yes'
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
end

group :develop do
  gem 'rake'
  gem 'rubocop', '>= 0.80.1', require: false
end

group :test do
  gem 'codecov', require: false
  gem 'regexp-examples', '~> 1.5.1', require: false
  gem 'rspec', '>= 3.8'
  gem 'simplecov', require: false
end
