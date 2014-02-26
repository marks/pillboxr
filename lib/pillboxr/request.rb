# -*- encoding: utf-8 -*-
require 'httparty'
require_relative 'response'

module Pillboxr
  class Request
    include HTTParty
    format :xml
    base_uri Pillboxr.config.base_uri
    parser(Class.new(HTTParty::Parser) do
            def parse
              begin
                body.gsub!(/^<disclaimer>.+<\/disclaimer>/, "")
                body.gsub!(/\&/, '&amp;')
                super
              rescue MultiXml::ParseError => e
                if e.message == Pillboxr.config.no_records_error_message or body == Pillboxr.config.no_records_response
                  result = {'Pills' => {'pill' => [], 'record_count' => 0 }}
                  return result
                elsif e.message == Pillboxr.config.api_key_error_message
                  raise "Invalid api_key. Check format and try again."
                else
                  raise
                end
              end
            end
          end)

    attr_reader :full_path, :params, :api_response

    def initialize(path = default_path, api_params)
      @full_path = path + api_params.concatenate
      @params = api_params
      @api_response = Pillboxr::Response.new
      @api_response.query = self
    end

    def perform
      puts "path = #{full_path}"
      @api_response.body = self.class.get(full_path)
      return self.api_response
    end

    # Assign an API key to this session.
    # @param [String] your API key in string format.
    def self.api_key=(arg)
      @api_key = arg
    end

    private
    def self.api_key
      case @api_key
      when String
        return @api_key
      when Pathname
        if @api_key.absolute?
          return YAML.load_file(@api_key)
        else
          return YAML.load_file(@api_key.realpath)
        end
      when File
        return YAML.load_file(@api_key)
      when nil
        begin
          return YAML.load_file(File.expand_path("api_key.yml"))
        rescue Errno::ENOENT => e
          raise e, "API key not found. Please create an api_key.yml file in the current working directory of the project or pass the key as an argument."
        rescue TypeError => e
          raise e, "The api_key.yml in this directory does not contain an appropriate key."
        end
      when Object
        begin
          return @api_key.key
        rescue NoMethodError => e
          raise e, "The object passed as an argument to api_key= must respond to the 'key' method."
        end
      else
        raise ArgumentError, "api_key must be one of 'String', 'Pathname', 'File', or an object that responds to the 'key' method."
      end
    end

    def default_path
      "/PHP/pillboxAPIService.php?key=#{self.class.api_key}"
    end
  end
end
