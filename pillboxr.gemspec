# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pillboxr', __FILE__)
require File.expand_path('../lib/pillboxr/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "pillboxr"
  s.version     = Pillboxr::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Keith Gautreaux', 'David Hale', 'Darius Roberts']
  s.email       = ['keith.gautreaux@gmail.com']
  s.homepage    = "http://rubygems.org/gems/pillboxr"
  s.summary     = "Access the NLM Pillbox API using ActiveResource."
  s.description = <<-END
Pillboxr is a Ruby wrapper for the National Library of Medicine Pillbox API Service located at [http://pillbox.nlm.nih.gov](http://pillbox.nlm.nih.gov).

The pillbox API provides information from the FDA about various prescription medications.

The current version of this library has two forms. The first (preferred) version does not depend on any gems except for `httparty`.
The second version depends upon `active_resource`.
This version of Pillboxr inherits from ActiveResource to perform its XML wrapping so ActiveResource 3.2.6 is a requirement for using the wrapper.
This version is deprecated and will be removed in the future.

*Note:* This library is designed for use with Ruby 1.9.3 and above, and will not work with earlier versions of Ruby.
END

  s.required_rubygems_version = ">= 1.8.6"
  s.rubyforge_project         = "pillboxr"

  s.add_dependency 'activeresource', '~> 3.2.6'

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "activeresource", "~> 3.2.6"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end