require_relative '../logic/options'

require_relative 'cache'

module DSL
  module Global
    def api
      Cache.instance.global_api
    end

    def state
      Cache.instance.global_state
    end

    def config(options = {})
      options = Logic::Options[:normalize].(options)

      if Cache.instance.api_keys?(options)
        Cache.instance.global_api(options, recreate: true)
      end

      return unless Cache.instance.state_keys?(options)

      Cache.instance.global_state(options, recreate: true)

      nil
    end

    def cached(all: false)
      return Cache.instance.keys if all

      Cache.instance.keys.select { |key| key[/^global/] }
    end

    def clear
      Cache.instance.clear_global!
    end

    module_function :api, :state, :config, :cached, :clear
  end
end
