module Pillboxr
  class Pills
    extend Forwardable
    def_delegators :@data, :<<, :size, :each, :include?, :empty?

    attr_accessor :record_count, :pages, :page

    def initialize(pills, params)
      @data = []
      @record_count = Integer(pills['record_count'])
      @record_count.divmod(RECORDS_PER_PAGE).tap { |ary| ary[1] == 0 ? @pages = ary[0] : @pages = ary[0] + 1 }
      @page = Integer(params.limit / RECORDS_PER_PAGE ) + 1 # One indexed.
      @query_params = params.dup
    end

    def to_s
      string = "#<Pillboxr::Pills:#{object_id} "
      instance_variables.each do |ivar|
        next if ivar == :@data
        string << String(ivar)
        string << " = "
        string << (String(self.instance_variable_get(ivar)) || "")
        string << ", "
      end unless instance_variables.empty?
      string << "size = #{self.size}"
      string << ">"
      return string
    end

    alias_method :inspect, :to_s
  end
end