# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in rggen.gemspec
gemspec

root = ENV['RGGEN_ROOT'] || File.expand_path('..', __dir__)
gemfile = File.join(root, 'rggen-devtools', 'gemfile', 'common.gemfile')
eval_gemfile(gemfile)

group :rggen do
  gem_patched 'facets'
  gem_patched 'rubyzip'
end

for_ci do
  gem_bundled 'racc'
end
