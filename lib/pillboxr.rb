# -*- encoding: utf-8 -*-
require 'httparty'
require_relative 'extensions'
require_relative 'pill'
require_relative 'params'

module Pillboxr
  # include Attributes
  include HTTParty
  format :xml
  base_uri 'pillbox.nlm.nih.gov'
  parser(Class.new(HTTParty::Parser) do
            def parse
              body.gsub!(/^<disclaimer>.+<\/disclaimer>/, "")
              body.gsub!(/\s\&\s/, ' and ')
              # puts body
              super
            end
          end)

  def complete(remainder_path)
    puts "path = #{default_path + remainder_path}"
    begin
      return init_objects(get(default_path + remainder_path))
    rescue MultiXml::ParseError => e
      if e.message == "The document \"No records found\" does not have a valid root"
        puts "0 records retrieved."
        pills = []
        pills.define_singleton_method(:record_count) { 0 }
        return pills
      else
        raise
      end
    ensure
      @params.clear unless @params.empty?
    end
  end

  def with(arguments_hash)
    @params ||= Params.new(self)
    arguments_hash.each do |k,v|
      if attributes.keys.include?(k)
        @params << symbol_to_instance(k,v)
      elsif api_attributes.keys.include?(k)
        puts "#{api_attributes.fetch(k)} => #{v}"
        @params << symbol_to_instance(api_attributes.fetch(k),v)
      else
        raise "Invalid attributes hash."
        next
      end
    end
    # request_string = "#{default_path}#{@params.join('&')}"
    # puts "request_string = #{request_string}"
    # complete(request_string)
    complete(@params.concatenate)
  end

  def respond_to_missing?(method_name, include_private = false) # :nodoc:
    (attributes.keys.include?(method_name) || attributes.values.include?(method_name))
  end

  def method_missing(method_name, *args, &block) # :nodoc:
    @params ||= Params.new(self)
    if attributes.keys.include?(method_name)
      # puts "method_missing called with #{method_name}."
      @params << symbol_to_instance(method_name, args.first)
    elsif api_attributes.keys.include?(method_name)
      # puts "method_missing called with #{method_name}."
      with({ api_attributes.fetch(method_name) => args.first })
    else
      super
    end
  end

  private
  def init_objects(hash)
    pills = []
    pills.define_singleton_method(:record_count) { hash['Pills']['record_count'].to_i }
    puts "#{hash['Pills']['record_count']} records retrieved."
    if Integer(hash['Pills']['record_count']) == 1
      pills << Pill.new(hash['Pills']['pill'])
    else
      hash['Pills']['pill'].each do |pill|
        pills << Pill.new(pill)
      end
    end
    return pills
  end

  def symbol_to_instance(symbol, value)
    klass = String(symbol).gsub(/_/, "").capitalize
    klass.extend(Pillboxr::Extensions) unless klass.methods.include?(:to_constant)
    klass.to_constant.new(value)
  end

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