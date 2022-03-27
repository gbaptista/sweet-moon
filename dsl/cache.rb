require 'singleton'

require_relative '../controllers/api'
require_relative '../controllers/interpreter'
require_relative '../controllers/state'

require_relative 'api'
require_relative 'sweet_moon'

module DSL
  class Cache
    include Singleton

    API_KEYS = %i[shared_objects api_reference global_ffi]
    STATE_KEYS = %i[interpreter package_path package_cpath]

    def api_keys?(options)
      API_KEYS.each { |key| return true if options.key?(key) }
      false
    end

    def state_keys?(options)
      STATE_KEYS.each { |key| return true if options.key?(key) }
      false
    end

    def clear_global!
      @cache[:global_state]&._unsafely_destroy

      @cache.each_key { |key| @cache.delete(key) if key[/^global/] }
    end

    def keys
      @cache.keys
    end

    def initialize
      @cache = {}
    end

    def global_state(options = {}, recreate: false)
      key = :global_state

      clear_global_state_cache!(options) if recreate

      return @cache[key] if @cache[key]

      api = Cache.instance.api_module(options, :global_api_module)
      interpreter = Cache.instance.interpreter_module(
        api, options, :global_interpreter_module
      )

      @cache[key] = DSL::State.new(api, interpreter, Controller::State, options)
      @cache[key].instance_eval('undef :destroy', __FILE__, __LINE__)

      @cache[key]
    end

    def global_api(options = {}, recreate: false)
      key = :global_api

      clear_global_api_cache! if recreate

      @cache[key] ||= api(options, :global_api, :global_api_module)
    end

    def api(options = {}, key = nil, api_module_key = nil)
      key ||= cache_key_for(:api, options, API_KEYS)
      @cache[key] ||= DSL::Api.new(api_module(options, api_module_key))
    end

    def api_module(options = {}, key = nil)
      key ||= cache_key_for(:api_module, options, API_KEYS)
      @cache[key] ||= Controller::API[:handle!].(options)
    end

    def interpreter_module(api, options = {}, key = nil)
      key ||= cache_key_for(
        :interpreter_module,
        { shared_objects: api[:meta][:elected][:shared_objects],
          api_reference: api[:meta][:elected][:api_reference],
          global_ffi: api[:meta][:global_ffi],
          interpreter: options[:interpreter], package_path: options[:package_path],
          package_cpath: options[:package_cpath] },
        API_KEYS.concat(STATE_KEYS)
      )

      @cache[key] ||= Controller::Interpreter[:handle!].(api, options)
    end

    def cache_key_for(prefix, options = {}, relevant_keys = [])
      values = [prefix]

      relevant_keys.each do |key|
        value = options[key]
        value = options[key.to_s] if value.nil?

        values << (value.is_a?(Array) ? value.sort.join(':') : value.inspect)
      end

      values.join('|')
    end

    private

    def clear_global_api_cache!
      @cache[:global_state]&._unsafely_destroy

      %i[global_api global_api_module
         global_interpreter_module
         global_state].each do |key|
        @cache.delete(key)
      end
    end

    def clear_global_state_cache!(options)
      @cache[:global_state]&._unsafely_destroy

      %i[global_interpreter_module global_state].each do |key|
        @cache.delete(key)
      end

      return unless api_keys?(options)

      %i[global_api global_api_module].each do |key|
        @cache.delete(key)
      end

      global_api(options, recreate: true)
    end
  end
end
