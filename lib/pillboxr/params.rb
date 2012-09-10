# -*- encoding: utf-8 -*-
module Pillboxr
  class Params < Array

    def initialize(size = 0, obj = nil, module_name, &block)
      @module_name = module_name
      super(size, obj, &block)
    end

    def concatenate
      self.collect(&:to_param).join
    end

    def get(options = {}, &block)
      if options[:page]
        self << Pillboxr::Attributes::Lowerlimit.new(options.fetch(:page) * RECORDS_PER_PAGE)
      end
      @module_name.send(:complete, self, &block)
    end

    def limit
      if self.any? { |param| param.respond_to?(:lower_limit)}
        limit = self.select { |param| param.respond_to?(:lower_limit) }.first.lower_limit
        return limit
      else
        return DEFAULT_LOWER_LIMIT
      end
    end

    def respond_to_missing?(method_name, include_private = false) # :nodoc:
      @module_name.send(:respond_to?, method_name)
    end

    def method_missing(method_name, *args) # :nodoc:
      # puts "Params method missing called with #{method_name}."
      @module_name.send(:method_missing, method_name, *args)
    end
  end
end