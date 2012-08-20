module Pillboxr
  class Params < Array

    attr_accessor :limit

    def initialize(size = 0, obj = nil, module_name, limit, &block)
      @module_name = module_name
      @limit = limit
      super(size, obj, &block)
    end

    def concatenate
      self.collect(&:to_param).join
    end

    def all
      @module_name.send(:complete, concatenate)
    end

    def <<(item)
      @limit = item.lower_limit if item.respond_to?(:lower_limit)
      super
    end

    def respond_to_missing(method_name, include_private = false) # :nodoc:
      @module_name.send(:respond_to_missing, method_name, include_private)
    end

    def method_missing(method_name, *args)
      # puts "Params method missing called with #{method_name}."
      @module_name.send(:method_missing, method_name, *args)
    end
  end
end