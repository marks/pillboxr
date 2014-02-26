# -*- encoding: utf-8 -*-
require_relative 'test_helper'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'test/pillboxr/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end

class TestPillboxr < MiniTest::Unit::TestCase
  def setup
    @num_round_shape_records = 14275
    @num_blue_color_records = 3035
    @num_image_records = 11779
    @num_blue_records_with_image = 1177
    @num_5_mm_records = 5511
    @num_mylan_records = 800
    @request_object = Pillboxr::Request.new(Pillboxr::Params.new([Pillboxr::Attributes::Shape.new(:round)]))
  end

  def teardown
    Pillboxr.api_key = nil
  end

  def test_api_key
    assert_raises(NoMethodError) { Pillboxr.api_key }
    assert_raises(NoMethodError) do
      @request_object.api_key
    end
    Pillboxr.api_key = "foo"
    assert_equal("foo", Pillboxr::Request.send(:api_key))
    assert_raises(RuntimeError) { Pillboxr.with({:api_key => 'bar', :color => :blue}) }
    assert_equal("bar", Pillboxr::Request.send(:api_key))
  end

  def test_returns_the_correct_default_path
    assert_raises(NoMethodError) { @request_object.default_path }
    assert_equal("/PHP/pillboxAPIService.php?key=#{@request_object.class.send(:api_key)}", @request_object.send(:default_path))
  end

  def test_returns_number_of_records
    VCR.use_cassette(:round_shape) do
      assert_equal(@num_round_shape_records, Pillboxr.with(:shape => :round).record_count)
    end
  end

  def test_returns_no_records
    VCR.use_cassette(:foo_shape) do
      assert_equal(0, Pillboxr.with(:shape => :foo).record_count)
    end
  end

  def test_all_valid_colors
    VCR.use_cassette(:all_valid_colors) do
      Pillboxr::Attributes::COLORS.keys.each do |color|
        refute_equal([], Pillboxr.with(:color => color))
      end
    end
  end

  def test_multiple_colors
    VCR.use_cassette(:multiple_colors) do
      r = Pillboxr.with({color: [:blue, :green]}).pages.current.pills
      r.each do |pill|
        assert_includes(pill.color, :blue)
        assert_includes(pill.color, :green)
      end
    end
  end

  def test_all_valid_shapes
    VCR.use_cassette(:all_valid_shapes) do
      Pillboxr::Attributes::SHAPES.keys.each do |shape|
        case shape
        when :gear
          assert_empty(Pillboxr.with(:shape => shape).pages.first.pills)
        when :heptagon
          assert_empty(Pillboxr.with(:shape => shape).pages.first.pills)
        else
          refute_empty(Pillboxr.with(:shape => shape).pages.first.pills, "shape is #{shape}")
        end
      end
    end
  end

  def test_product_code
    VCR.use_cassette(:product_code) do
      assert_equal(1, Pillboxr.with({:product_code => "0078-0176"}).record_count)
    end
  end

  def test_combination_hash
    VCR.use_cassette(:combination_hash) do
      assert_equal(@num_blue_records_with_image, Pillboxr.with({ :color => "blue", :image => true }).record_count)
    end
  end

  def test_with_block_form
    VCR.use_cassette(:with_block_form) do
      @result = Pillboxr.with({:color => :blue}) do |r|
        r.pages.each do |page|
          page.get unless page.retrieved?
        end
      end
    end
    @result.pages.each { |page| assert page.retrieved? }
    assert_equal(@num_blue_color_records, @result.pages.inject(0) { |sum, page| sum + page.pills.size })
  end

  def test_respond_to_missing
    VCR.use_cassette(:respond_to_missing_shape) do
      assert_equal(true, Pillboxr.respond_to?(:shape))
    end
  end

  def test_method_missing_with_shape
    VCR.use_cassette(:method_missing_shape) do
      assert_equal(@num_round_shape_records, Pillboxr.shape(:round).get.record_count)
    end
  end

  def test_method_missing_with_image
    VCR.use_cassette(:method_missing_has_image) do
      @result = Pillboxr.image(true).get
    end

    @result.pages.first.pills.each do |pill|
      refute_nil(pill.image_url(:small))
    end
    assert_equal(@num_image_records, @result.record_count)
  end

  def test_method_missing_with_color
    VCR.use_cassette(:method_missing_color) do
      assert_equal(@num_blue_color_records, Pillboxr.color(:blue).get.record_count)
    end
  end

  # def test_method_missing_with_imprint # Broken currently
  #   VCR.use_cassette(:method_missing_imprint) do
  #     assert_equal(@num_imprint_23_records, Pillboxr.imprint(23).get.record_count)
  #   end
  # end

  def test_method_missing_with_size
    VCR.use_cassette(:method_missing_size, :match_requests_on => [:body], :allow_playback_repeats => true) do
      assert_equal(@num_5_mm_records, Pillboxr.size(5).get.record_count)
      assert_equal(@num_5_mm_records, Pillboxr.size("5").get.record_count)
    end
  end

  def test_method_missing_with_author
    VCR.use_cassette(:method_missing_author) do
      assert_equal(@num_mylan_records, Pillboxr.author("Mylan Pharmaceuticals Inc.").get.record_count)
    end
  end

  def test_method_missing_with_lower_limit
    VCR.use_cassette(:method_missing_with_lower_limit, :allow_playback_repeats => true) do
      assert_equal(201, Pillboxr.shape(:round).lower_limit(202).get.pages.current.pills.size)
    end
  end

  def test_with_lower_limit
    VCR.use_cassette(:with_lower_limit, :allow_playback_repeats => true) do
      assert_equal(201, Pillboxr.with({ :shape => :round, :lower_limit => 202 }).pages.current.pills.size)
      first = Pillboxr.with({ :shape => :round }).pages.current.pills
      second = Pillboxr.with({ :shape => :round, :lower_limit => 202 }).pages.current.pills
      first.each { |p| refute_includes(second, p)}
    end
  end

  def test_method_chaining
    VCR.use_cassette(:method_chaining) do
      assert_equal(@num_blue_records_with_image, Pillboxr.color(:blue).image(true).get.record_count)
    end
  end

  def test_method_missing_with_a_block
    VCR.use_cassette(:method_missing_with_a_block) do
      @result = Pillboxr.image(true).get do |r|
        r.pages.each do |page|
          page.get unless page.retrieved?
        end
      end
    end
    @result.pages.each { |page| assert page.retrieved? }
    assert_equal(@num_image_records, @result.pages.inject(0) { |sum, page| sum + page.pills.size })
  end

  def test_get_method_with_options
    VCR.use_cassette(:get_method_with_options) do
      @result = Pillboxr.image(true).get(page: 3)
      assert_equal(3, @result.pages.current.number)
    end
  end

  def test_empty_record_set_response_caught
    VCR.use_cassette(:empty_record_set) do
      no_records_response = Pillboxr.config.no_records_response
      Pillboxr.config.no_records_response = "foo"
      no_records_error_message = Pillboxr.config.no_records_error_message
      Pillboxr.config.no_records_error_message = "bar"
      assert_raises(MultiXml::ParseError) do
        @result = Pillboxr.with(:color => [:blue,:green], :size => 100)
      end
      Pillboxr.config.no_records_error_message = no_records_error_message
      Pillboxr.config.no_records_response = no_records_response
    end
  end
end
