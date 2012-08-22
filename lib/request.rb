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
                body.gsub!(/^<disclaimer>.+<\/disclaimer>/, "")
                body.gsub!(/\s\&\s/, ' and ')
                super
              end
            end)

    attr_reader :full_path, :params, :api_response

    def initialize(default_path = default_path, params)
      @full_path = default_path + params.concatenate
      @params = params
      @api_response = Pillboxr::Response.new
      @api_response.query = self
    end

    def perform
      puts "path = #{default_path + params.concatenate}"
      begin
        @api_response.body = self.class.get(full_path)
      rescue MultiXml::ParseError => e
        if e.message == "The document \"No records found\" does not have a valid root"
          puts "0 records retrieved."
          result = []
          result.define_singleton_method(:record_count) { 0 }
          return result
        else
          raise
        end
      end
      return self.api_response
    end

    private
    def api_key
      begin
        @api_key ||= YAML.load_file(File.expand_path("api_key.yml"))
      rescue Errno::ENOENT => e
        raise e, "API key not found. You must create an api_key.yml file in the root directory of the project."
      end
    end

    def default_path
      "/PHP/pillboxAPIService.php?key=#{api_key}"
    end
  end
end