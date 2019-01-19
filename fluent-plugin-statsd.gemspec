# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-statsd-output"
  gem.description = "fluentd output filter plugin to send metrics to Esty StatsD"
  gem.homepage    = "https://github.com/imnotjames/fluent-plugin-statsd"
  gem.summary     = gem.description
  gem.version     = File.read("VERSION").strip
  gem.license     = "MIT"
  gem.authors     = ["James Ward", "Chris Song"]
  gem.email       = "james@notjam.es"
  gem.has_rdoc    = false
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']
  gem.required_ruby_version = ">= 2.1.0"

  gem.add_dependency "fluentd", ">= 0.10.8"
  gem.add_dependency "statsd-ruby", "~> 1.4"

  gem.add_development_dependency "rspec", '~> 3.0'
  gem.add_development_dependency "test-unit"
  gem.add_development_dependency "pry"
end
