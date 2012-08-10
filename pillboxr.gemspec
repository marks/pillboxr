# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pillboxr', __FILE__)
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "pillboxr"
  s.version     = Pillboxr::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Keith Gautreaux', 'David Hale', 'Darius Roberts']
  s.email       = ['keith.gautreaux@gmail.com']
  s.homepage    = "http://rubygems.org/gems/pillboxr"
  s.summary     = "Access the NLM Pillbox API using ActiveResource."
  s.description = <<-END
Pillboxr is a subclass of ActiveResource::Base that provides additional convenience methods and some parameter wrapping for querying the Pillbox API Service located at http://pillbox.nlm.nih.gov/PHP/pillboxAPIService.php
END

  s.required_rubygems_version = ">= 1.8.6"
  s.rubyforge_project         = "pillboxr"
  
  s.add_dependency 'activeresource', '> 2.3.5'

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "activeresource", "> 3.2.5"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end