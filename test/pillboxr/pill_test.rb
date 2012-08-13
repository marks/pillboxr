require_relative 'test_helper'

class TestPill < MiniTest::Unit::TestCase
  def setup
    @blue_pills = Pillboxr.color(:blue).image(true).all
    @scored_pills = Pillboxr.score(3).all
  end

  def test_accessor_methods
    @blue_pills.each do |pill|
      assert_equal(:blue, pill.color)
      assert_equal(true, pill.image?)
    end

    @scored_pills.each do |pill|
      assert_equal(true, pill.scored?)
      assert_equal(3, pill.score)
    end
  end
end