module Spodunk
  module Connection
    class Base
      attr_reader :session, :spreadsheet

      # the interface between Hash objects and Google Spreadsheets
      def initialize(*args)
        @tables = {}
      end

      

      def load_table(title)
        unless title.nil?
          @tables[title] = {}
          @tables[title][:real] = real_t = fetch_real_table_object(title)
          @tables[title][:podunk] = init_podunk_table(real_t, title: title)
        end
      end




      def load_spreadsheet(*args);end

      def real_tables(tid)
        if t = @tables[tid]
          return t[:real]
        end
      end

      def tables(tid)
        if t = @tables[tid]
          return t[:podunk]
        end
      end

      def save_row(table_id, row)
        pt = tables(table_id)
        row_idx = pt.real_row_index(row)

        row.itemized_changes.each_pair do |col_idx, val|
          save_cell(table_id, row_idx, col_idx, val)
        end
      end

      def save_table(table_id)
        pt = tables(table_id)

        # expects itemized_changes to be {[2,3] => 4}
        #  with row_offset and col_offset already applied
        pt.itemized_changes.each_pair do |(r, c), val|
          save_cell(table_id, r, c, val)
        end
      end

      # arr_xy is something like [2,3] (row 2, col 3)
      #  expects arr_xy to contain offset-applied row and col index
      def save_cell(table_id, real_row_idx, real_col_idx, val)
        # abstract
      end





      protected
      def init_podunk_table(*args); end
      def fetch_real_table_object(*args); end

    end
  end
end

require 'spodunk/connections/gdrive'
