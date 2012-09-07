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

  def test_to_param
    Pillboxr::Attributes::COLORS.each do |k,v|
      color = Pillboxr::Attributes::Color.new(k)
      assert_equal("&color=#{v}", color.to_param)
    end
    Pillboxr::Attributes::SHAPES.each do |k,v|
      shape = Pillboxr::Attributes::Shape.new(k)
      assert_equal("&shape=#{v}", shape.to_param)
    end
    Pillboxr::Attributes::DEA_CODES.each do |k,v|
      code = Pillboxr::Attributes::Schedule.new(k)
      assert_equal("&dea=#{v}", code.to_param)
    end
  end
end