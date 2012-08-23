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

end