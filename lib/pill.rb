# -*- encoding: utf-8 -*-
require_relative 'attributes'

module Pillboxr
  include Attributes
  extend self
  class Pill
    Pillboxr.attributes.each do |k,v|
      attr_accessor k.to_sym
      alias_method v.to_sym, k.to_sym
      alias_method (v.to_s + "=").to_sym, (k.to_s + "=").to_sym
    end

    def initialize(params_hash)
      params_hash.each do |k,v|
        self.send((k.downcase + "=").to_sym, v)
      end
    end

    def color
      Pillboxr::Attributes::COLOR_CODES[@color.to_sym]
    end

    def shape
      Pillboxr::Attributes::SHAPE_CODES[@shape.to_sym]
    end

    def score
      @score.to_i == 1 ? true : false
    end

    def score?
      @score.to_i == 1 ? true : false
    end

    def image
      @image.to_i == 1 ? true : false
    end

    def image?
      @image.to_i == 1 ? true : false
    end

    def to_s
      string = "#<Pillboxr::Pill:#{object_id} "
      instance_variables.each do |ivar|
        string << String(ivar)
        string << " = "
        string << (self.instance_variable_get(ivar) || "")
        string << ", "
      end unless instance_variables.empty?
      string << ">"
    end

    def image_url(image_size = 'super_small')
      unless image_id
        return nil
      end
      case String(image_size)
        when "super_small"; "http://pillbox.nlm.nih.gov/assets/super_small/#{image_id}ss.png"
        when "small";       "http://pillbox.nlm.nih.gov/assets/small/#{image_id}sm.jpg"
        when "medium";      "http://pillbox.nlm.nih.gov/assets/medium/#{image_id}md.jpg"
        when "large";       "http://pillbox.nlm.nih.gov/assets/large/#{image_id}lg.jpg"
        when "all"
          ["http://pillbox.nlm.nih.gov/assets/super_small/#{image_id}ss.png",
           "http://pillbox.nlm.nih.gov/assets/small/#{image_id}sm.jpg",
           "http://pillbox.nlm.nih.gov/assets/medium/#{image_id}md.jpg",
           "http://pillbox.nlm.nih.gov/assets/large/#{image_id}lg.jpg"]
      end
    end
  end
end