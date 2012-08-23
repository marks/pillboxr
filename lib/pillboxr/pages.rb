# -*- encoding: utf-8 -*-
require 'forwardable'

module Pillboxr
  class Pages
    extend ::Forwardable
    def_delegators :@data, :<<, :size, :each, :include?, :empty?, :count, :join, :first, :last, :[], :[]=

    def initialize(size = 0, obj = nil, &block)
      @data = Array.new(size, &block)
    end

    def inspect
      string = "#<Pillboxr::Result::Pages:#{object_id} ["
      @data.each do |page|
        string << String(page)
        string << ", "
      end
      string << "], size = #{self.size}>"
      return string
    end

    alias_method :to_s, :inspect

    def start
      self.current = @data[0]
    end

    def start?
      self.current == @data[0]
    end

    def end
      self.current = @data[-1]
    end

    def end?
      self.current == @data[-1]
    end

    def advance(slots = 1)
      slots.times { self.current = self.next }
      return self.current
    end

    def retreat(slots = 1)
      slots.times { self.current = self.previous }
      return self.current
    end

    def next(slots = 1)
      if slots == 1
        self.end? ? @data[0] : @data[current_index + 1]
      else
        if slots <= (@data.size - (current_index + 1))
          @data[(current_index + 1), slots]
        else
          temporary_array = @data[(current_index + 1)..-1].push(@data[0..(current_index - 1)]).flatten
          return temporary_array[0..(slots - 1)]
        end
      end
    end

    def previous(slots = 1)
      if slots == 1
        self.start? ? @data[-1] : @data[current_index - 1]
      else
        if slots <= current_index
          @data[(current_index - slots)..(current_index - 1)]
        else
          (@data[0..(current_index - 1)].reverse.push(@data[(current_index - slots)..-1].reverse)).flatten
        end
      end
    end

    def current
      @data[current_index]
    end

    def current=(page)
      unless page.current?
        self.current.send(:current=, false)
        page.send(:current=, true)
      end
      return page
    end

    def current_index
      @data.index { |page| page.current }
    end

    private :current_index
  end
end