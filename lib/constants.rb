# -*- encoding: utf-8 -*-
module Pillboxr
    RECORDS_PER_PAGE = 201
  module Attributes
    SHAPES = {
        :bullet=> :C48335,
        :capsule=> :C48336,
        :clover=> :C48337,
        :diamond=> :C48338,
        :double_circle=> :C48339,
        :freeform=> :C48340,
        :gear=> :C48341,
        :heptagon=> :C48342,
        :hexagon=> :C48343,
        :octagon=> :C48344,
        :oval=> :C48345,
        :pentagon=> :C48346,
        :rectangle=> :C48347,
        :round=> :C48348,
        :semi_circle=> :C48349,
        :square=> :C48350,
        :tear=> :C48351,
        :trapezoid=> :C48352,
        :triangle=> :C48353
    }

    SHAPE_CODES = SHAPES.invert

    COLORS = {
        :black => :C48323,
        :blue => :C48333,
        :brown => :C48332,
        :gray => :C48324,
        :green => :C48329,
        :orange => :C48331,
        :pink => :C48328,
        :purple => :C48327,
        :red => :C48326,
        :turquoise => :C48334,
        :white => :C48325,
        :yellow => :C48330
    }

    COLOR_CODES = COLORS.invert

    DEA_CODES = {
        :I   => :C48672,
        :II  => :C48675,
        :III => :C48676,
        :IV  => :C48677,
        :V   => :C48679
    }

    SCHEDULE_CODES = DEA_CODES.invert
  end
end