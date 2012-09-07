# -*- encoding: utf-8 -*-
require_relative 'test_helper'
require_relative '../../lib/pillboxr/response'

class TestResponse < MiniTest::Unit::TestCase
  def setup
    @response = Pillboxr::Response.new("body", "query")
  end

  def test_body_retrieval
    assert_equal("body", @response.body)
  end

  def test_query_string_retrieval
    assert_equal("query", @response.query)
  end

  def test_passing_a_query_string
    r = Pillboxr::Response.new("body", "foo")
    assert_equal("foo", r.query)
  end

  def test_passing_a_body
    r = Pillboxr::Response.new("foo", "query")
    assert_equal("foo", r.body)
  end
end