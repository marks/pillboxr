# -*- encoding: utf-8 -*-
require_relative 'test_helper'

class TestAttributes < MiniTest::Unit::TestCase
  def setup
    extend Pillboxr::Attributes
  end

  def test_fetching_an_attribute
    assert_equal(:splcolor, attributes.fetch(:color))
  end

  def test_fetching_an_api_attribute
    assert_equal(:color, api_attributes.fetch(:splcolor))
  end
end