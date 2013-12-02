$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'dotenv'
dotpath = File.expand_path File.join(File.dirname(__FILE__), '..', '.env')
# puts dotpath
Dotenv.load dotpath

require 'spodunk'
include Spodunk



@creds = {email: ENV['GDRIVE_TEST_EMAIL'], password: ENV['GDRIVE_TEST_PASSWORD']}
@url = ENV['GDRIVE_TEST_SPREADSHEET_URL']
@title = ENV['GDRIVE_TEST_WORKSHEET_TITLE']

@gd = Connection::GDrive.new(@creds, url: @url)
@gd.load_table('models')

@rows = @gd.table('models').rows


