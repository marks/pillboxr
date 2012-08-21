# -*- encoding: utf-8 -*-
require 'httparty'

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

    attr_reader :full_path

    def initialize(default_path = default_path, params)
      @full_path = default_path + params.concatenate
    end

    def perform
      self.class.get(full_path)
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