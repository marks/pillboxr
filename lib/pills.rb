module Pillboxr
  class Pills
    extend Forwardable
    def_delegators :@data, :<<, :size, :each, :include?, :empty?, :count, :join, :first, :last, :[]

    attr_accessor :record_count, :pages, :page

    def initialize(pills, params = Params.new(Pillboxr, DEFAULT_LOWER_LIMIT))
      @data = []
      page_number = Integer(params.limit / RECORDS_PER_PAGE )
      @record_count = Integer(pills['record_count'])
      @record_count.divmod(RECORDS_PER_PAGE).tap do |ary|
        if ary[1] == 0
          @pages = Array.new(ary[0]) { |i| Page.new(page_number == i, i) }
        else
          @pages = Array.new(ary[0] + 1) { |i| Page.new(page_number == i, i)}
        end
      end
      @query_params = params.dup unless params.empty?
      @page = @pages.each.tap do |enum| # @page is an enumerator for the @pages array
        enum.instance_exec do
          def inspect
           "<#Enumerator: page: #{number}>"
          end

          def to_s
           inspect
          end

          def respond_to_missing?(method_name, include_private = false)
            self.peek.respond_to?(method_name.to_sym)
          end

          def method_missing(method_name, *args, &block)
            self.peek.send(method_name.to_sym, *args, &block)
          end
        end
      end

      match_enum(@page, page_number)
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

    def all
      @data.to_s
    end

    alias_method :inspect, :to_s

    Page = Struct.new(:retrieved, :number) do
      def inspect
        "<Page: retrieved: #{retrieved}, number: #{number}>"
      end
    end

    def get_page(requested_page) # zero indexed
      @query_params.delete_if { |param| param.respond_to?(:lower_limit) }
      @query_params << Pillboxr::Attributes::Lowerlimit.new((requested_page.number) * RECORDS_PER_PAGE) # zero indexed
      if Pillboxr.complete(@query_params.concatenate).each { |pill| self << pill }
        match_enum(@page, requested_page.number)
        @pages[requested_page.number].retrieved = true
      else
        raise "Could not fetch that page."
      end
    end

    def get_next_page
      if @pages.last.number == @page.number
        puts "No more pages of results to fetch."
      else
        get_page(@page.next)
      end
    end

    def get_previous_page
      if @pages.first.number == @page.number
        puts "Already at first page of results."
      else
      end
    end

    private

    def match_enum(enum, current_number)
      begin
        enum.next until enum.number == current_number
      rescue StopIteration
        enum.rewind
        enum.next until enum.number == current_number
      end
    end
  end
end