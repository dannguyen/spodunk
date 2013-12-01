require 'google_drive'


module Spodunk
  class Boss
    attr_reader :session, :spreadsheet

    # the interface between Hash objects and Google Spreadsheets
    def initialize(creds, sheet_opts={})
      # old style auth
      if creds[:email] && creds[:password]
        @session = GoogleDrive.login creds[:email], creds[:password]
      end

      @active_tables = {}

      # url is something like:
      # 
      # https://docs.google.com/spreadsheet/ccc?key=xXcdHmAt3Q3D3lDx&usp=drive_web#gid=0
      if url = sheet_opts[:url]
        @spreadsheet = open_spreadsheet(parse_gdoc_url_for_key(url))
        if title = sheet_opts[:title]
          open_table!(title) 
        end        
      end
    end

    
    # intializes a new table, basically
    def save_and_reload_table!(title=nil)
      tbl = table(title)

      open_table!(tbl.title)
    end

    def table(title = nil)
      title.nil? ? @active_tables.values.first : @active_tables[title]
    end


    private

    # returns a string for key
    def parse_gdoc_url_for_key(url)
      u = URI.parse(url)
 
      key = CGI.parse(u.query)['key'][0]
    end

    def open_table!(title)
      return nil if title.nil?
      gsheet = open_worksheet(title)
      @active_tables[title] =  Table.create_from_gdoc(gsheet, title: title)
           
      return @active_tables[title]   
    end

    def open_spreadsheet(key)
      @session.spreadsheet_by_key(key)
    end

    def open_worksheet(title)
      @spreadsheet.worksheet_by_title(title)
    end

  end
end