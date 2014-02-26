# -*- encoding: utf-8 -*-
require 'singleton'

module Pillboxr
  class Config
    include Singleton
    
    attr_accessor :records_per_page,
                  :default_lower_limit,
                  :no_records_error_message,
                  :no_records_response,
                  :api_key_error_message

    attr_reader :base_uri

    def initialize(options = {})
      @records_per_page    = 201
      @default_lower_limit = 1
      @base_uri = 'pillbox.nlm.nih.gov'
      @no_records_error_message = "The document \"No records found\" does not have a valid root"
      @no_records_response = "No records found"
      @api_key_error_message = "The document \"Key does not match, you may not access this service\" does not have a valid root"
    end
  end
  # Global config object
  def config
    Config.instance
  end

  def config=(hash)
    Config.send(:new, hash)
  end
    
  module_function :config
end

