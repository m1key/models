# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'models/version'

Gem::Specification.new do |spec|
  spec.name          = 'models'
  spec.version       = Models::VERSION
  spec.authors       = ['Michal Huniewicz']
  spec.email         = ['michal.huniewicz.registered@gmail.com']

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: Set to \'http://mygemserver.com\' to prevent pushes to rubygems.org, or delete to allow pushes to any server.'
  end

  spec.summary       = 'Playing with Neo4j and Ruby.'
  spec.description   = 'Playing with Neo4j and Ruby.'
  spec.homepage      = 'TODO: Put your gem\'s website or public repo URL here.'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_runtime_dependency 'json', '= 1.8.2'
  spec.add_runtime_dependency 'neo4j-core', '= 4.0.2'
  spec.add_runtime_dependency 'htmlentities', '= 4.3.3'
end
