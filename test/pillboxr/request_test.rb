# -*- encoding: utf-8 -*-
require_relative 'test_helper'

class TestRequest < MiniTest::Unit::TestCase
  def test_setting_api_key
    Pillboxr.api_key = "foo"
    assert_equal("foo", Pillboxr::Request.send(:api_key))
  end
end