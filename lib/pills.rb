module Pillboxr
  class Result

    attr_accessor :record_count, :pages

    def initialize(api_response, params = Params.new(Pillboxr, DEFAULT_LOWER_LIMIT))
      @pages = Pages.new
      pills = []
      page_number = Integer(params.limit / RECORDS_PER_PAGE )
      @record_count = Integer(api_response['Pills']['record_count'])
      if @record_count == 1
        pills << Pill.new(api_response['Pills']['pill'])
      else
        api_response['Pills']['pill'].each do |pill|
          pills << Pill.new(pill)
        end
      end
      @record_count.divmod(RECORDS_PER_PAGE).tap do |ary|
        if ary[1] == 0
          @pages = Pages.new(ary[0]) { |i| Page.new(false, false, i, []) }
          @pages[page_number] = Page.new(true, true, page_number, pills)
        else
          @pages = Pages.new(ary[0] + 1) { |i| Page.new(false, false, i, [])}
          @pages[page_number] = Page.new(true, true, page_number, pills)
        end
      end

      @query_params = params.dup unless params.empty?
      return self
    end

    def inspect
      string = "#<Pillboxr::Result:#{object_id} "
      instance_variables.each do |ivar|
        string << String(ivar)
        string << " = "
        string << (String(self.instance_variable_get(ivar)) || "")
        string << ", "
      end unless instance_variables.empty?
      string << ">"
      return string
    end

    alias_method :to_s, :inspect

    class Pages
      extend Forwardable
      def_delegators :@data, :<<, :size, :each, :include?, :empty?, :count, :join, :first, :last, :[], :[]=

      def initialize(size = 0, obj = nil, &block)
        @data = Array.new(size, obj, &block)
      end

      def inspect
        string = "#<Pillboxr::Result::Pages:#{object_id} ["
        @data.each do |page|
          string << String(page)
          string << ", "
        end
        string << "], size = #{self.size}>"
        return string
      end

      alias_method :to_s, :inspect

      def next
        @current ||= @data.index { |page| page.current }
        @current == (@data.size - 1) ? @data[0] : @data[@current]
      end

      def previous
        start ? @data[-1] : @data[current]
      end

      def current
        @current ||= @data.index { |page| page.current }
      end

      def current=(index)
        @data[current].current = false
        @data[index].current = true
      end
    end

    Page = Struct.new(:current, :retrieved, :number, :pills) do
      def inspect
        "<Page: current: #{current}, retrieved: #{retrieved}, number: #{number}, #{pills.size} pills>"
      end

      alias_method :to_s, :inspect
    end
  end
end