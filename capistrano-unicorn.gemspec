# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name        = "capistrano-unicorn"
  gem.version     = "0.1.7"
  gem.author      = "Kyle Miller"
  gem.email       = "github@backupparachute.com"
  gem.homepage    = "https://github.com/backupparachute/capistrano-unicorn"
  gem.summary     = %q{Unicorn integration for Capistrano}
  gem.description = %q{Capistrano plugin for Unicorn tasks.}
  gem.license     = "MIT"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency     "capistrano", "< 3.0"
end
