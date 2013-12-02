require 'active_support/all'

module Spodunk
  NULL_FIELD_VALUE = "!NULL"
end

require 'spodunk/connection'
require 'spodunk/table'
require 'spodunk/row'


class String
  def slugify
    self.underscore.parameterize.underscore
  end
end