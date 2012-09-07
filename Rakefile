# -*- encoding: utf-8 -*-
require 'rake'
require 'rake/testtask'
require 'bundler'
begin
  require 'pry'
rescue LoadError
  require 'irb'
end

Bundler::GemHelper.install_tasks

Rake::TestTask.new(:standalone_test) do |test|
  test.libs << 'lib' << 'test/pillboxr'
  test.pattern = 'test/pillboxr/**/*_test.rb'
  test.verbose = true
end

task :console do
  if Kernel.const_defined?(:Pry)
    Pry.start
  else
    IRB.start
  end
end

task :c => :console

task :default => :standalone_test