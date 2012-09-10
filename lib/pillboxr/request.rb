# -*- encoding: utf-8 -*-
require 'httparty'
require_relative 'response'

module Pillboxr
  class Request
    include HTTParty
    format :xml
    base_uri BASE_URI
    parser(Class.new(HTTParty::Parser) do
            def parse
              begin
                body.gsub!(/^<disclaimer>.+<\/disclaimer>/, "")
                body.gsub!(/\s\&\s/, ' and ')
                super
              rescue MultiXml::ParseError => e
                if e.message == NO_RECORDS_ERROR_MESSAGE
                  result = {'Pills' => {'pill' => [], 'record_count' => 0 }}
                  return result
                elsif e.message == API_KEY_ERROR_MESSAGE
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
    def self.api_key=(str)
      @api_key = str
    end

    private
    def self.api_key
      begin
        @api_key ||= YAML.load_file(File.expand_path("api_key.yml"))
      rescue Errno::ENOENT => e
        raise e, "API key not found. You must create an api_key.yml file in the root directory of the project."
      rescue TypeError => e
        raise e, "api_key.yml does not contain an appropriate key."
      end
    end

    def default_path
      "/PHP/pillboxAPIService.php?key=#{self.class.api_key}"
    end
  end
end