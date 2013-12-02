module Spodunk

  class RowCollection
    include Enumerable

    attr_reader :rows, :table, :headers
    delegate :each, :[], :index, :to => :rows

    def initialize(_rows, _headers, tbl=nil)
      @table = tbl
      @headers = _headers
      @rows = spodunk_rows(_rows)
    end


    def spawn(_rows)
      RowCollection.new(_rows, self.headers, self.table)
    end

    # not tested at all, obv
    def where(&blk)
      spawn(@rows.select(&blk))
    end


    private
    def spodunk_rows(rts)
      rts.map{ |r| r.is_a?(Spodunk::Row) ? r : Spodunk::Row.new(r, @headers, table: @table)}
    end
  end
end