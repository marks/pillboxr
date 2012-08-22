module Pillboxr
  class Result

    attr_accessor :record_count, :pages

    def initialize(api_response)
      initial_page_number = Integer(api_response.query.params.limit / RECORDS_PER_PAGE )
      @record_count = Integer(api_response.body['Pills']['record_count'])

      puts "#{@record_count} records available. #{RECORDS_PER_PAGE} records retrieved."

      @pages = initialize_pages_array(api_response, initial_page_number)
      @pages[initial_page_number].send(:pills=, self.class.parse_pills(api_response))
      return self
    end

    def self.subsequent(api_response)
      return parse_pills(api_response)
    end

    def self.parse_pills(api_response)
      pills = []
      if @record_count == 1
        pills << Pill.new(api_response.body['Pills']['pill'])
      else
        api_response.body['Pills']['pill'].each do |pill|
          pills << Pill.new(pill)
        end
      end
      return pills
    end

    def initialize_pages_array(api_response, initial_page_number)
      record_count.divmod(RECORDS_PER_PAGE).tap do |ary|
        if ary[1] == 0
          return Pages.new(ary[0]) do |i|
            page_params = api_response.query.params.dup
            page_params.delete_if { |param| param.respond_to?(:lower_limit)}
            page_params << Attributes::Lowerlimit.new(i * RECORDS_PER_PAGE)
            Page.new(i == initial_page_number, i == initial_page_number, i, [], page_params)
          end
        else
          return Pages.new(ary[0] + 1) do |i|
            page_params = api_response.query.params.dup
            page_params.delete_if { |param| param.respond_to?(:lower_limit)}
            page_params << Attributes::Lowerlimit.new(i * RECORDS_PER_PAGE)
            Page.new(i == initial_page_number, i == initial_page_number, i, [], page_params)
          end
        end
      end
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
    private :initialize_pages_array

    class Pages
      extend Forwardable
      def_delegators :@data, :<<, :size, :each, :include?, :empty?, :count, :join, :first, :last, :[], :[]=, :inject

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

      def start
        self.current = @data[0]
      end

      def start?
        self.current == @data[0]
      end

      def end
        self.current = @data[-1]
      end

      def end?
        self.current == @data[-1]
      end

      def advance(slots = 1)
        slots.times { self.current = self.next }
        return self.current
      end

      def retreat(slots = 1)
        slots.times { self.current = self.previous }
        return self.current
      end

      def next(slots = 1)
        if slots == 1
          self.end? ? @data[0] : @data[current_index + 1]
        else
          if slots <= (@data.size - (current_index + 1))
            @data[(current_index + 1), slots]
          else
            temporary_array = @data[(current_index + 1)..-1].push(@data[0..(current_index - 1)]).flatten
            return temporary_array[0..(slots - 1)]
          end
        end
      end

      def previous(slots = 1)
        if slots == 1
          self.start? ? @data[-1] : @data[current_index - 1]
        else
          if slots <= current_index
            @data[(current_index - slots)..(current_index - 1)]
          else
            (@data[0..(current_index - 1)].reverse.push(@data[(current_index - slots)..-1].reverse)).flatten
          end
        end
      end

      def current
        @data[current_index]
      end

      def current=(page)
        unless page.current?
          self.current.send(:current=, false)
          page.send(:current=, true)
        end
        return page
      end

      def current_index
        @data.index { |page| page.current }
      end

      private :current_index
    end

    Page = Struct.new(:current, :retrieved, :number, :pills, :params) do
      # extend Pillboxr
      def inspect
        "<Page: current: #{current}, retrieved: #{retrieved}, number: #{number}, params: #{params}, #{pills.size} pills>"
      end

      def current?
        self.current == true
      end

      def retrieved?
        self.retrieved == true
      end

      def get
        unless self.retrieved
          self.pills = Result.subsequent(Request.new(self.params).perform)
          self.retrieved = true
        end
      end

      alias_method :to_s, :inspect
      private :current=, :retrieved=, :number=, :pills=, :params=
    end
  end
end