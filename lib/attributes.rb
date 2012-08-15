# -*- encoding: utf-8 -*-
require_relative 'constants'
require 'erb'

module Pillboxr
  module Attributes
    def attributes
      { :color                => :splcolor,
        :shape                => :splshape,
        :product_code         => :product_code,
        :schedule             => :dea_schedule_code,
        :ingredients          => :ingredients,
        :imprint              => :splimprint,
        :id                   => :spl_id,
        :ndc9                 => :ndc9,
        :size                 => :splsize,
        :score                => :splscore,
        :rxcui                => :rxcui,
        :rxtty                => :rxtty,
        :rxstring             => :rxstring,
        :image                => :has_image,
        :image_id             => :image_id,
        :setid                => :setid,
        :author               => :author,
        :inactive_ingredients => :spl_inactive_ing,
        :lower_limit          => :lower_limit }
    end

    def api_attributes
      attributes.invert
    end

    # Creates a series of class methods on Pillboxr::Attributes module
    # that allow easy access to all the possible colors, shapes, dea codes, etc..
    # Example:
    #
    # Pillboxr::Attributes.colors
    # => [:bullet,:capsule,:clover,:diamond,:double_circle,:freeform,:gear,:heptagon,
    #     :hexagon,:octagon,:oval,:pentagon,:rectangle,:round,:semi_circle,:square,
    #     :tear,:trapezoid,:triangle]
    #
    # Available methods are colors, color_codes, shapes, shape_codes, dea_codes,
    # and schedule_codes.
    self.constants.each do |const|
      self.module_eval("def self.#{const.downcase}; #{const}.keys; end")
    end

    class Color
      attr_accessor :color

      def initialize(color_arg)
        # puts "argument to method = #{color_arg}"
        @color = case color_arg
        when NilClass;  raise ColorError
        when Array;     color_arg.size > 1 ? Pill::Attributes::Colors.new(color_arg) : COLORS[color_arg[0]]
        when Symbol;    COLORS.fetch(color_arg, color_arg)
        when String;    COLORS.fetch(color_arg.to_sym, color_arg.to_sym)
        else raise "invalid arguments."
        end
        return self
      end

      def to_param
        "&color=" + String(@color)
      end
    end

    class Shape
      attr_accessor :shape

      def initialize(shape_arg)
        # puts "argument to method = #{shape_arg}"
        @shape = case shape_arg
        when NilClass;              raise ShapeError
        when Array;                 shape_arg.size > 1 ? Pill::Attributes::Shapes.new(color_arg) : SHAPES[shape_arg[0]]
        when /^([Cc]{1}\d{5})+/;    shape_arg # valid hex
        when Symbol;                SHAPES.fetch(shape_arg, shape_arg)
        when String;                SHAPES.fetch(shape_arg.to_sym, shape_arg.to_sym)
        else raise "invalid arguments."
        end
        return self
      end

      def to_param
        "&shape=" + String(@shape)
      end
    end

    class Productcode
      attr_accessor :product_code

      def initialize(product_code_arg)
        # puts "argument to method = #{product_code_arg}"
        @code = case product_code_arg
        when NilClass;   raise ProductcodeError
        when Array;      raise "product_code must be unique."
        when /^\d+-\d+/; product_code_arg # valid hex
        when Symbol;     raise "product_code cannot be a symbol."
        else raise "invalid arguments."
        end
        return self
      end

      def to_param
        "&prodcode=" + String(@code)
      end
    end

    class Schedule
      attr_accessor :schedule

      def initialize(schedule_code)
        # puts "argument to method = #{schedule_code}"
        @schedule = case schedule_code
        when NilClass;                  raise ScheduleError
        when Array;                     schedule_code.size > 1 ? Pill::Attributes::Schedules.new(color_arg) : DEA_CODES.fetch(schedule_code[0])
        when /^([Cc]{1}\d{5})+/;        schedule_code # valid hex
        when /\AI{1,3}\z|\AIV\z|\AV\z/; DEA_CODES.fetch(schedule_code, schedule_code)
        else raise "invalid arguments."
        end
        return self
      end

      def to_param
        "&dea=" + String(@schedule)
      end
    end

    class Ingredients
      attr_accessor :ingredients

      def initialize(ingredient_arg)
        # puts "argument to method = #{ingredient_arg}"
        @ingredients = case ingredient_arg
        when NilClass; raise IngredientError
        when Array;    raise ArgumentError, "can only search for one active ingredient at this time."
        when String;   ingredient_arg
        when Symbol;   String(ingredient_arg)
        else raise ArgumentError, "invalid arguments."
        end
        return self
      end

      def to_param
        "&ingredient=" + String(@ingredients)
      end
    end

    # class Imprint # Broken currently
    #   attr_accessor :imprint

    #   def initialize(imprint_arg)
    #     # puts "argument to method = #{ingredient_arg}"
    #     @imprint = case imprint_arg
    #     when NilClass; raise ImprintError
    #     when Array;    raise ArgumentError, "can only search for one imprint string at this time."
    #     when String;   imprint_arg
    #     when Symbol;   imprint_arg
    #     when Integer;  imprint_arg
    #     else raise ArgumentError, "invalid arguments."
    #     end
    #     return self
    #   end

    #   def to_param
    #     "&imprint=" + String(@imprint)
    #   end
    # end

    class Size
      attr_accessor :size

      def initialize(size_arg)
        @size = case size_arg
        when NilClass; raise SizeError
        when Integer;  size_arg
        when Float;    Integer(size_arg)
        when String;   Integer(size_arg)
        when Symbol;   Integer(size_arg)
        else raise ArgumentError, "invalid arguments."
        end
        return self
      end

      def to_param
        "&size=" + String(@size)
      end

    end


    class Score
      attr_accessor :score

      def initialize(score_arg)
        # puts "argument to method = #{score_arg}"
        @score = case score_arg
        when NilClass;   raise ScoreError
        when TrueClass;  2
        when FalseClass; 1
        when Integer;    score_arg
        when Array;      raise ArgumentError, "Must be true or false."
        else raise ArgumentError, "invalid arguments."
        end
        return self
      end

      def to_param
        "&score=" + String(@score)
      end
    end

    class Image
      attr_accessor :image

      def initialize(image_arg)
        # puts "argument to method = #{image_arg}"
        @image = case image_arg
        when NilClass;   raise ImageError
        when TrueClass;  1
        when FalseClass; 0
        when Array;      raise ArgumentError, "Must be true or false."
        else raise ArgumentError, "invalid arguments."
        end
        return self
      end

      def to_param
        "&has_image=" + String(@image)
      end
    end

    class Author
      attr_accessor :author

      def initialize(author_arg)
        @author = case author_arg
        when String; author_arg
        when Array;  raise ArgumentError, "Author can only take a single string."
        else raise ArgumentError, "invalid arguments."
        end
        return self
      end

      def to_param
        "&author=" + ERB::Util.url_encode(@author)
      end
    end

    class Lowerlimit
      attr_accessor :lower_limit

      def initialize(limit = 0)
        @lower_limit = case limit
        when NilClass; raise LowerLimitError
        when Integer;  limit
        else raise ArgumentError, "Lower limit must be an integer."
        end
        return self
      end

      def to_param
        "&lower_limit=" + String(@lower_limit)
      end
    end
  end
end
