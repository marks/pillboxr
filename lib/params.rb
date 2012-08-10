module Pillboxr
  class Params < Array
    def initialize(module_name)
      @module_name = module_name
    end
    
    def concatenate
      self.join
    end
    
    def all
      @module_name.send(:complete, concatenate)
    end
    
    def respond_to_missing(method_name, include_private = false) # :nodoc:
      @module_name.send(:respond_to_missing, method_name, include_private)
    end
    
    def method_missing(method_name, args)
      @module_name.send(:method_missing, method_name, args)
    end
  end
end