module Pillboxr
  class Result

    attr_accessor :record_count, :pages

    def initialize(api_response, params = Params.new(Pillboxr, DEFAULT_LOWER_LIMIT))
      @pages = Pages.new
      pills = []
      puts "params.limit = #{params.limit}"
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
          @pages = Pages.new(ary[0]) { |i| Page.new(false, false, i, [], params.dup) }
          @pages[page_number] = Page.new(true, true, page_number, pills, params.dup)
        else
          @pages = Pages.new(ary[0] + 1) { |i| Page.new(false, false, i, [], params.dup)}
          @pages[page_number] = Page.new(true, true, page_number, pills, params.dup)
        end
      end

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
          self.params << Pillboxr::Attributes::Lowerlimit.new(self.number * RECORDS_PER_PAGE)
          puts self.params
          puts self.number
          if result = Pillboxr.complete(self.params.concatenate, self.params)
            puts result.pages[self.number]
            self.pills = result.pages[self.number].pills
            self.retrieved = true
          else
            raise "Error fetching page."
          end
        end
      end

      alias_method :to_s, :inspect
      private :current=, :retrieved=, :number=, :pills=, :params=
    end
  end
end