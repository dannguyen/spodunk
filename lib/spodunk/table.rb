require 'active_support/all'

module Spodunk
  class Table

    attr_reader :headers, :rows, :title

    def initialize(arr, opts={})
      rs = arr.dup
      @headers = rs.shift
      @rows = rs.map{ |r| Row.new(r, @headers)}

      @title = opts[:title]
    end


    def num_rows
      @rows.count
    end

    def num_cols
      @headers.count
    end

    def clean_rows
      @rows.reject{|r| r.dirty?}
    end

    def dirty_rows
      @rows.select{|r| r.dirty?}
    end

    def clean?
      dirty_rows.empty?
    end

    def dirty?
      !clean?
    end

    # returns with 0-based index and column names as Strings
    def changes(opts={})
      offset = opts[:offset].to_i

      dirty_rows.inject({}) do |h, row|
        idx = @rows.index(row) + offset
        h[idx] = row.changes(opts)
 
        h
      end     
    end

    # returns format more specific for Google Worksheets
    # with 1-based index and Hash with column indices rather than
    #  Strings
    def worksheet_changes
      changes(offset: 1)
    end

    # similar to worksheet_changes, except hash contains keys
    # of [row, val] Arrays
    def itemized_changes
      worksheet_changes.inject({}) do |h, (row_num, col_hsh) |
        col_hsh.each_pair do |col_num, val|
          h[[row_num, col_num]] = val
        end
        
        h
      end
    end

  # define unique ID field or concatenation


    class << self
      def create_from_gdoc(gsheet)
        self.new(gsheet.rows)
      end
    end

  end
end