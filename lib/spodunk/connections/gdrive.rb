require 'google_drive'
module Spodunk
  module Connection
    class GDrive < Base

      # the interface between Hash objects and Google Spreadsheets
      def initialize(creds, sheet_opts={})
        # old style auth
        if creds[:email] && creds[:password]
          @session = GoogleDrive.login creds[:email], creds[:password]
        end
        @spreadsheet = load_spreadsheet(sheet_opts)

        super
      end

      


      # url is something like:
      # 
      # https://docs.google.com/spreadsheet/ccc?key=xXcdHmAt3Q3D3lDx&usp=drive_web#gid=0
      def load_spreadsheet(opts)
        if opts[:url]
          @session.spreadsheet_by_key parse_gdoc_url_for_key(opts[:url])
        elsif opts[:key]
          @session.spreadsheet_by_key(opts[:key])
        end
      end


      # via: https://github.com/gimite/google-drive-ruby#how-to-use
      def save_cell(table_id, real_row_idx, real_col_idx, val)
        r_table = real_tables(table_id) # i.e. a Google Worksheet
        r_table[real_row_idx, real_col_idx] = val

        r_table.save
      end


      protected
      # returns a string for key
      def parse_gdoc_url_for_key(url)
        u = URI.parse(url)
   
        key = CGI.parse(u.query)['key'][0]
      end


      # sets up the table structure
      def init_podunk_table(gsheet, opts={})
        opts[:connection] = self
        Table.new(gsheet.rows, opts)
      end


      def fetch_real_table_object(title)
        @spreadsheet.worksheet_by_title(title)
      end


    end
  end
end