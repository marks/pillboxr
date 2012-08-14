module Pillboxr
  class Pills < Array

    attr_accessor :record_count, :pages, :page, :saved_params

    def initialize(size = 0, obj = nil, pills, params, &block)
      @record_count = Integer(pills['record_count'])
      @record_count.divmod(RECORDS_PER_PAGE).tap { |ary| ary[1] == 0 ? @pages = ary[0] : @pages = ary[0] + 1 }
      @page = Integer(params.limit / RECORDS_PER_PAGE ) + 1 # One indexed.
      @saved_params = params
      # super(size, obj, &block)
    end
  end
end