require 'snoop-rails/version'
require 'snoop-rails/config'

# Snoop description...
#
# Prior to using it, you must {configure} it.
#
# @example
#   Snoop.configure do |c|
#     c.project_id = 113743
#     c.project_key = 'fd04e13d806a90f96614ad8e529b2822'
#   end
#
#   Snoop.send_event('some event details')

module Snoop
  # The general error that this library uses when it wants to raise.
  Error = Class.new(StandardError)

  # returns string representing the label to be prepended to the log output
  LOG_LABEL = '**Snoop:'.freeze

  class << self
    # Configures Snoop.
    #
    # @example
    #   Snoop.configure do |c|
    #     c.project_id = 113743
    #     c.project_key = 'fd04e13d806a90f96614ad8e529b2822'
    #   end
    def configure
      yield config = Snoop::Config.instance
    end
  end
end
