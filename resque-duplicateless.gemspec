# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "resque-duplicateless/version"

Gem::Specification.new do |spec|
  spec.name          = "resque-duplicateless"
  spec.version       = ResqueDuplicateless::VERSION
  spec.authors       = ["Jeremy Linder"]
  spec.email         = ["jeremy@nomibeauty.com"]

  spec.summary       = %q{Allow for unique Resque Jobs on the queue}
  spec.description   = %q{Resque allows a single queue to have multiple jobs of the same time. This is because it uses a redis list, which does not have the concept of a unique entry. Sometimes, however, a particular value is only needed if it isn't already on the queue.}
  spec.homepage      = "https://www.nomibeauty.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_dependency "resque", "~> 1.x"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
end
