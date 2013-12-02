require 'active_support/all'

module Spodunk
  class Table

    attr_reader :headers, :rows, :title, :slug_headers, 
                :row_offset, :col_offset

    def initialize(arr, opts={})
      rs = arr.dup
      @headers = rs.shift
      @slug_headers = @headers.map{|h| h.slugify}
      # rows get attributes as slugs
      @rows = rs.map{ |r| Row.new(r, @slug_headers)}

      @title = opts[:title]

      # most spreadsheets start counting from 1
      # and the first row is technically at index-2
      #  since headers is index-1
      @row_offset = opts[:row_offset] || 2

      # most spreadsheets begin column counting at 1
      @col_offset = opts[:col_offset] || 1
    end

    def real_row_index(row)
      if row.is_a?(Fixnum)
        idx = row
      else
        idx = @rows.index(row)
      end

      return idx + @row_offset
    end


    def num_rows
      @rows.count
    end

    def num_cols
      @headers.count
    end


    def valid?
      @slug_headers.uniq.count == num_cols
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
      row_offset = opts[:row_offset].to_i

      dirty_rows.inject({}) do |h, row|
        idx = @rows.index(row) + row_offset
        h[idx] = row.changes(opts)
 
        h
      end     
    end

    # returns format more specific for Google Worksheets
    # with 1-based index and Hash with column indices rather than
    #  Strings
    def offset_changes
      changes(col_offset: @col_offset, row_offset: @row_offset)
    end

    # similar to offset_changes, except hash contains keys
    # of [row, val] Arrays
    def itemized_changes
      offset_changes.inject({}) do |h, (row_num, col_hsh) |
        col_hsh.each_pair do |col_num, val|
          h[[row_num, col_num]] = val
        end
        
        h
      end
    end

  # define unique ID field or concatenation


   

  end
end