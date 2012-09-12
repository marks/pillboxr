# -*- encoding: utf-8 -*-
require_relative 'test_helper'

class TestRequest < MiniTest::Unit::TestCase
  def teardown
    Pillboxr.api_key = nil
  end

  def test_passing_string_to_api_key
    Pillboxr.api_key = "foo"
    assert_equal("foo", Pillboxr::Request.send(:api_key))
  end

  def test_passing_pathname_to_api_key
    Pillboxr.api_key = Pathname.new("./test/pillboxr/fixtures/api_key.yml")
    assert_equal("foo", Pillboxr::Request.send(:api_key), "You probably need to create an api_key.yml file in the fixtures directory.")
  end

  def test_passing_file_to_api_key
    Pillboxr.api_key = File.open("./test/pillboxr/fixtures/api_key.yml", "r")
    assert_equal("foo", Pillboxr::Request.send(:api_key), "You probably need to create an api_key.yml file in the fixtures directory.")
  end

  def test_passing_object_to_api_key
    Pillboxr.api_key = Object.new.tap { |obj| obj.define_singleton_method(:key) { "foo" } }
    assert_equal("foo", Pillboxr::Request.send(:api_key))
  end

  def test_passing_no_argument_to_api_key
    assert_equal(YAML.load_file("api_key.yml"), Pillboxr::Request.send(:api_key))
  end

  def test_invalid_object
    Pillboxr.api_key = Object.new
    assert_raises(NoMethodError) { Pillboxr::Request.send(:api_key) }
  end

  def test_passing_hash_to_api_key
    Pillboxr.api_key = {}
    assert_raises(ArgumentError) { Pillboxr::Request.send(:api_key) }
  end
end