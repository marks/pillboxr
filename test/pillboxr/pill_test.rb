require_relative 'test_helper'

class TestPill < MiniTest::Unit::TestCase
  def setup
    @pills = Pillboxr.color(:blue).image(true).all
  end

  def test_accessor_methods
    @pills.each do |pill|
      assert_equal(:blue, pill.color)
      assert_equal(true, pill.image?)
    end
  end
end