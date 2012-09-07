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
    @num_round_shape_records = 11773
    @num_blue_color_records = 2059
    @num_image_records = 748
    @num_blue_records_with_image = 69
    @num_5_mm_records = 4724
    @num_mylan_records = 753
    @request_object = Pillboxr::Request.new(Pillboxr::Params.new([Pillboxr::Attributes::Shape.new(:round)]))
  end

  def test_api_key
    assert_raises(NoMethodError) { Pillboxr::Request.api_key }
    assert_raises(NoMethodError) do
      @request_object.api_key
    end
  end

  def test_returns_the_correct_default_path
    assert_raises(NoMethodError) { @request_object.default_path }
    assert_equal("/PHP/pillboxAPIService.php?key=#{@request_object.send(:api_key)}", @request_object.send(:default_path))
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
      assert_equal(@num_round_shape_records, Pillboxr.shape(:round).all.record_count)
    end
  end

  def test_method_missing_with_image
    VCR.use_cassette(:method_missing_has_image) do
      @result = Pillboxr.image(true).all
    end

    @result.pages.first.pills.each do |pill|
      refute_nil(pill.image_url(:small))
    end
    assert_equal(@num_image_records, @result.record_count)
  end

  def test_method_missing_with_color
    VCR.use_cassette(:method_missing_color) do
      assert_equal(@num_blue_color_records, Pillboxr.color(:blue).all.record_count)
    end
  end

  # def test_method_missing_with_imprint # Broken currently
  #   VCR.use_cassette(:method_missing_imprint) do
  #     assert_equal(@num_imprint_23_records, Pillboxr.imprint(23).all.record_count)
  #   end
  # end

  def test_method_missing_with_size
    VCR.use_cassette(:method_missing_size, :allow_playback_repeats => true) do
      assert_equal(@num_5_mm_records, Pillboxr.size(5).all.record_count)
      assert_equal(@num_5_mm_records, Pillboxr.size("5").all.record_count)
    end
  end

  def test_method_missing_with_author
    VCR.use_cassette(:method_missing_author) do
      assert_equal(@num_mylan_records, Pillboxr.author("Mylan Pharmaceuticals Inc.").all.record_count)
    end
  end

  def test_method_missing_with_lower_limit
    VCR.use_cassette(:method_missing_with_lower_limit, :allow_playback_repeats => true) do
      assert_equal(201, Pillboxr.shape(:round).lower_limit(202).all.pages.current.pills.size)
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
      assert_equal(@num_blue_records_with_image, Pillboxr.color(:blue).image(true).all.record_count)
    end
  end

  def test_method_missing_with_a_block
    VCR.use_cassette(:method_missing_with_a_block) do
      @result = Pillboxr.image(true).all do |r|
        r.pages.each do |page|
          page.get unless page.retrieved?
        end
      end
    end
    @result.pages.each { |page| assert page.retrieved? }
    assert_equal(@num_image_records, @result.pages.inject(0) { |sum, page| sum + page.pills.size })
  end
end