require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dummy
  class MutableUsernameEnvResolver
    attr_accessor :username

    def initialize(username)
      @username = username
    end

    def current
      "#{username}"
    end
  end

  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.console1984.protected_environments = %i[ production test development ]
    config.console1984.protected_urls = [ "localhost:#{6379}", "http://elastic:changeme@localhost:39201" ]
    config.console1984.ask_for_username_if_empty = true
    config.console1984.username_resolver = MutableUsernameEnvResolver.new("jorge")
    Lockbox.master_key = Lockbox.generate_key

    config.active_record.encryption.encrypt_fixtures = true
  end
end
