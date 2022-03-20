require_relative '../logic/options'

require_relative 'cache'

module Global
  def api
    Cache.instance.global_api
  end

  def state
    Cache.instance.global_state
  end

  def config(options = {})
    options = Logic::Options[:normalize].(options)

    if options.key?(:shared_objects) || options.key?(:api_reference)
      Cache.instance.global_api(options, recreate: true)
    end

    return unless
      options.key?(:interpreter) ||
      options.key?(:package_path) ||
      options.key?(:package_cpath)

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
