# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "akismetor/version"

Gem::Specification.new do |s|
  s.name        = "akismetor"
  s.version     = Akismetor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robby Grossman", "Ryan Bates", "Levy Carneiro"]
  s.email       = ["robby@freerobby.com"]
  s.homepage    = ""
  s.summary     = %q{Spam protection with Akismet and Typepad}
  s.description = %q{Spam protection with Akismet and Typepad}

  s.rubyforge_project = "akismetor"
  
  s.add_development_dependency "rspec", ">= 2.4.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
