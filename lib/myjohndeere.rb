require 'net/http'
require 'json'
require 'rbconfig'
require 'base64'
require 'oauth'

# Errors
require 'myjohndeere/errors'

# Version
require 'myjohndeere/version'

# API Support Classes
require 'myjohndeere/access_token'

module MyJohnDeere
  class << self
    attr_accessor :configuration
  end

  JSON_CONTENT_HEADER_VALUE = 'application/vnd.deere.axiom.v3+json'
  ENDPOINTS = {
    sandbox: "https://sandboxapi.deere.com/platform",
    production: "https://api.soa-proxy.deere.com/platform"
  }
  AUTHORIZE_URL = "https://my.deere.com/consentToUseOfData"
  DEFAULT_REQUEST_HEADER = { 'accept'=> JSON_CONTENT_HEADER_VALUE }
  DEFAULT_POST_HEADER = { 
    'accept'=> JSON_CONTENT_HEADER_VALUE,
    "Content-Type"=> JSON_CONTENT_HEADER_VALUE
  }
  ETAG_HEADER_KEY = "x-deere-signature"

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :endpoint
    attr_writer :shared_secret, :app_id
    attr_reader :environment

    def environment=(val)
      @environment = val.to_sym
      @endpoint = ENDPOINTS[@environment]
      if @endpoint.nil?
        raise ConfigurationError.new('Invalid environment, you must use either :sandbox or :production. Sandbox is the default')
      end
    end

    def initialize
      # Assume the sandbox endpoint
      self.environment = :sandbox
      @shared_secret = nil
      @app_id = nil
    end

    def shared_secret
      if @shared_secret.nil? then
        raise ConfigurationError.new('No shared_secret provided in configuration. ' \
          'Please set this according to your Deere Developer app credentials.')
      end
    end

    def app_id
      if @app_id.nil? then
        raise ConfigurationError.new('No app_id provided in configuration. ' \
          'Please set this according to your Deere Developer app credentials.')
      end
    end
  end
end