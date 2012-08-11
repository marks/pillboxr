# -*- encoding: utf-8 -*-
$:.unshift File.dirname(File.dirname(__FILE__))
require 'minitest/autorun'
require_relative '../../lib/pillboxr'

class MiniTest::Unit::TestCase
  def deny(*args)
    args.each { |arg| assert !arg }
  end
end