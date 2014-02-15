# -*- encoding: utf-8 -*-
require_relative 'test_helper'

class TestPill < MiniTest::Unit::TestCase
  def setup
    @blue_pills = Pillboxr.color(:blue).image(true).get.pages.current.pills
    @scored_pills = Pillboxr.score(3).get.pages.current.pills
  end

  def test_color_returns_array
    @blue_pills.each do |pill|
      assert_instance_of(Array, pill.color)
    end
  end

  def test_shape_returns_array
    @scored_pills.each do |pill|
      assert_instance_of(Array, pill.shape)
    end
  end

  def test_accessor_methods
    @blue_pills.each do |pill|
      assert_includes(pill.color, :blue)
      assert_equal(true, pill.image?)
    end

    @scored_pills.each do |pill|
      assert_equal(true, pill.scored?)
      assert_equal(3, pill.score)
    end
  end
end
