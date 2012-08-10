# -*- encoding: utf-8 -*-
require_relative 'attributes'

module Pillboxr
  module Extensions
    def to_constant
      raise TypeError unless self.kind_of?(String)
      Array(self).inject(Pillboxr::Attributes) { |s,e| s.const_get(e.to_sym) }
    end
  end
end