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
      @params << "foo"
    end
    assert_equal("foofoofoofoofoo", @params.concatenate)
  end
  
end