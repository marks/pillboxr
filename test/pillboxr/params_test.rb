require_relative 'test_helper'

class TestParams < MiniTest::Unit::TestCase
  def setup
    @params = Pillboxr::Params.new(Pillboxr)
  end

  def test_creation_of_params
    assert_equal([], @params)
  end

  def test_concatenate_method
    5.times do
      @params << Pillboxr::Attributes::Lowerlimit.new(0)
    end
    assert_equal("&lower_limit=0&lower_limit=0&lower_limit=0&lower_limit=0&lower_limit=0", @params.concatenate)
  end

  def test_limit_method
    assert_equal(Pillboxr::DEFAULT_LOWER_LIMIT, @params.limit)
    @params << Pillboxr::Attributes::Lowerlimit.new(300)
    assert_equal(300, @params.limit)
  end

  def test_method_missing

  end
end