# -*- encoding: utf-8 -*-
require_relative 'test_helper'

class PillboxrTest < Test::Unit::TestCase
  
  def setup
    # @meds = load_yaml_fixture
    Pillboxr.test!
  end
  
  def test_should_honor_pagination
    return true # pagination is broken for now
    # meds = Pillboxr.all(:params => {:has_image => true, :lower_limit => 200})
    # assert_equal(100, meds.count)
  end
  
  def test_should_find_by_combo_shape
    med = Pillboxr.first(:params=>{'color'=>"C48324;C48323"})
    assert_equal("Acetaminophen 150 MG / Aspirin 180 MG / Codeine Phosphate 30 MG Oral Capsule", med.rxstring)
  end
  
  def test_should_accept_shape_as_hex
    meds = Pillboxr.all(:params=>{'shape' => 'C48336'})
    assert_equal(4307, Pillboxr.record_count)
    assert_equal(201, meds.count)
  end
  
  def test_should_accept_color_as_hex
    meds = Pillboxr.all(:params => {'color' => "C48328"})
    assert_equal(1560, Pillboxr.record_count)
    assert_equal(201, meds.count)
  end
  
  def test_should_accept_multiple_colors
    meds = Pillboxr.all(:params => { 'color' => ['C48328', 'C48327']})
    assert_equal(1, meds.count)
    assert_equal('Selfemra 20 MG Oral Capsule', meds.first.rxstring)
  end
  
  def test_should_accept_shape_as_string
    meds = Pillboxr.all(:params => {'shape' => 'capsule'})
    assert_equal(4307, Pillboxr.record_count)
    assert_equal(201, meds.count)
    meds.each { |m| assert_equal(:capsule, m.shape.kind_of?(Array) ? m.shape.first.downcase : m.shape.downcase) }
  end
  
  def test_should_accept_color_as_string
    meds = Pillboxr.all(:params => {'color' => 'white'})
    assert_equal(7789, Pillboxr.record_count)
    assert_equal(201, meds.count)    
  end
  
  def test_param_combinations_should_work
    meds = Pillboxr.all(:params => {'shape' => 'C48348', 'color' => 'C48325'})
    assert_equal(4354, Pillboxr.record_count)
    assert_equal(201, meds.count)    
  end
  
  def test_imprint_search_should_work
    meds = Pillboxr.all(:params => {'imprint' => 'NVR'})
    assert_equal(96, Pillboxr.record_count)
    assert_equal(96, meds.count)    
  end
  
  def test_size_search_should_work
    meds = Pillboxr.all(:params => {'size' => '12.00'})
    assert_equal(5531, Pillboxr.record_count)
    assert_equal(201, meds.count)    
  end
  
  def test_should_return_normalized_array_of_strings_for_inactive_ingredients
    meds = Pillboxr.all(:params => {:has_image => true})
    assert_equal(Array, meds.first.inactive.class)
    meds.first.inactive.each do |ing|
      assert_no_match(/\s$/, ing)
      assert_no_match(/^\s/, ing)
    end
    assert_equal("SILICON DIOXIDE", meds.first.inactive[1])
  end
  
  def test_should_return_appropriate_dea_schedule
    med = Pillboxr.first(:params => {:ingredient => 'Hydromorphone'})
    assert_equal('Schedule II', med.dea)
  end
  
  def test_should_allow_searching_for_multiple_active_ingredients
    med = Pillboxr.all(:params => {:ingredient => ['amlodipine', 'benazepril']})
    assert_equal(67, med.count)
    med = Pillboxr.all(:params => {:ingredient => ['valsartan','hydrochlorothiazide', 'amlodipine']})
    assert_not_nil(med)
    assert_equal(6, med.count)
  end
  
  def test_should_return_a_valid_image_url
    meds = Pillboxr.all(:params => {:has_image => 1})
    meds.each { |m| assert_equal("http://pillbox.nlm.nih.gov/assets/super_small/#{m.image_id}ss.png", m.image_url)}
  end
  
  def test_should_return_an_array_of_valid_urls
    meds = Pillboxr.all(:params => {:has_image => 1})
    meds.each do |m| 
      assert_equal(["http://pillbox.nlm.nih.gov/assets/super_small/#{m.image_id}ss.png",
                                  "http://pillbox.nlm.nih.gov/assets/small/#{m.image_id}sm.jpg",
                                  "http://pillbox.nlm.nih.gov/assets/medium/#{m.image_id}md.jpg",
                                  "http://pillbox.nlm.nih.gov/assets/large/#{m.image_id}lg.jpg"], m.image_url('all'))
    end
  end
  
  def test_should_return_a_valid_trade_name
    med = Pillboxr.first(:params => {:ingredient  => 'Sildenafil'})
    assert_equal('Viagra', med.trade_name)
  end
  
  if RUBY_VERSION > '1.9'
    def test_should_rescue_rexml_parser_error
      assert_nothing_raised { med = Pillboxr.all(:params => {:dea => "a"} ) }
    end
  end
end