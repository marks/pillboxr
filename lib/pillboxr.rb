# -*- encoding: utf-8 -*-

require_relative 'pillboxr/extensions'
require_relative 'pillboxr/result'
require_relative 'pillboxr/pill'
require_relative 'pillboxr/params'
require_relative 'pillboxr/request'

module Pillboxr

  def api_key=(str)
    Request.api_key = str
  end

  # Search API for pages of pills. Also accepts a block that yields pages for iterating through.
  # @param [Hash] search parameters, see {Pillboxr::Attributes} for accepted parameters.
  # @return [Result] a {Pillboxr::Result} object that has pages of data that can be iterated through.
  def with(options, &block)
    @params ||= Params.new(self)

    self.api_key = options.delete(:api_key)

    options.each do |k,v|
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

    complete(@params, &block)
  end

  def respond_to_missing?(method_name, include_private = false) # :nodoc:
    (attributes.keys.include?(method_name) || attributes.values.include?(method_name))
  end

  def method_missing(method_name, *args, &block) # :nodoc:
    @params ||= Params.new(self)
    if attributes.keys.include?(method_name)
      @params << symbol_to_instance(method_name, args.first)
    elsif api_attributes.keys.include?(method_name)
      @params << symbol_to_instance(api_attributes.fetch(method_name), args.first)
    else
      super
    end
  end

  def complete(params = @params, &block) # :nodoc:
    begin
      return Result.new(Request.new(params).perform, &block)
    ensure
      @params = Params.new(self)
    end
  end

  private

  def symbol_to_instance(symbol, value)
    klass = String(symbol).gsub(/_/, "").capitalize
    klass.extend(Pillboxr::Extensions) unless klass.methods.include?(:to_constant)
    klass.to_constant.new(value)
  end
end