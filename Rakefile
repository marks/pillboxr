# -*- encoding: utf-8 -*-
require 'rake'
require 'rake/testtask'
require 'bundler'

Bundler::GemHelper.install_tasks

Rake::TestTask.new(:standalone_test) do |test|
  test.libs << 'lib' << 'test/pillboxr' 
  test.pattern = 'test/pillboxr/**/*_test.rb'
  test.verbose = true
end

Rake::TestTask.new(:activeresource_test) do |test|
  test.libs = []
  test.libs << 'lib/active_resource' << 'test/pillboxr_activeresource' 
  test.pattern = 'test/pillboxr_activeresource/**/*_test.rb'
  test.verbose = true
end

task :all => [:standalone_test, :activeresource_test]

task :default => :standalone_test