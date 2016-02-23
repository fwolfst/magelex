# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'magelex/version'

Gem::Specification.new do |spec|
  spec.name          = "magelex"
  spec.version       = Magelex::VERSION
  spec.authors       = ["Felix Wolfsteller"]
  spec.email         = ["felix.wolfsteller@gmail.com"]
  spec.licenses      = ['GPL-3.0']

  spec.summary       = %q{Bridge for data from Magento shop to Lexware financial software.}
  spec.homepage      = "https://github.com/fwolfst/magelex"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'mysql2', '~> 0.4'
  spec.add_dependency 'terminal-table'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
