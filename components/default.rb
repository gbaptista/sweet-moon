require 'singleton'

module Component
  class Default
    include Singleton

    def initialize
      @config = { global_ffi: true }
    end

    def options
      @config
    end

    def set(key, value)
      @config[key.to_sym] = value
    end
  end
end
