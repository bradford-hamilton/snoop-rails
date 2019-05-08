module Snoop
  # Represents Snoop's config. A config contains all the options that you
  # can use to configure a Snoop instance.

  class Config
    # project_id: (Integer) the project identifier. This value *must* be set.
    attr_accessor :project_id

    # project_key: (String) the project key. This value *must* be set.
    attr_accessor :project_key

    # returns (String) of the host, which provides the API endpoint to which event data will be sent
    attr_accessor :host

    # returns (String, Pathname) of the working directory of your project
    # @api public
    attr_accessor :root_directory

    class << self
      # returns Config
      attr_writer :instance

      # returns Config
      def instance
        @instance ||= new
      end
    end

    # initialize takes a user_config: [Hash{Symbol=>Object}] the hash to be used to build the config
    def initialize(user_config = {})
      self.project_id = user_config[:project_id]
      self.project_key = user_config[:project_key]
      self.host = 'http://localhost:6666'
      self.root_directory = File.realpath(
        (defined?(Bundler) && Bundler.root) ||
        Dir.pwd
      )

      merge(user_config)

      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)

        Rails.logger.info "Event Controller: #{event.payload[:controller]}"
        Rails.logger.info "Event Params: #{event.payload[:params]}"
        Rails.logger.info "Event Action: #{event.payload[:action]}"
        Rails.logger.info "Event Start Time: #{event.time}"
        Rails.logger.info "Event End Time: #{event.end}"
        Rails.logger.info "Event Duration: #{event.duration}"
      end
    end

    # The full URL to the Snoop API. Based on the +:host+ option.
    def endpoint
      @endpoint ||=
        begin
          self.host = ('https://' << host) if host !~ %r{\Ahttps?://}
          api = "api/v1/projects/#{project_id}"
          URI.join(host, api)
        end
    end

    # Merges the given +config_hash+ with itself.
    #
    # Example:
    #   config.merge(host: 'localhost:8080')
    #
    # returns self: the merged config
    def merge(config_hash)
      config_hash.each_pair { |option, value| set_option(option, value) }
      self
    end

    private

    def set_option(option, value)
      __send__("#{option}=", value)
    rescue NoMethodError
      raise Snoop::Error, "unknown option '#{option}'"
    end
  end
end