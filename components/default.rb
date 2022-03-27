require 'singleton'

module Component
  class Default
    include Singleton

    attr_reader :options

    def initialize
      @options = { global_ffi: true }
    end

    def set(key, value)
      @options[key.to_sym] = value
    end
  end
end
