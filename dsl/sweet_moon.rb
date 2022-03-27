require_relative '../logic/options'
require_relative '../logic/spec'

require_relative 'cache'
require_relative 'state'
require_relative 'global'

require_relative '../logic/api'
require_relative '../logic/interpreter'

module SweetMoon
  module API
    def new(options = {})
      DSL::Cache.instance.api(Logic::Options[:normalize].(options))
    end

    module_function :new
  end

  module State
    def new(options = {})
      options = Logic::Options[:normalize].(options)

      api = DSL::Cache.instance.api_module(options)

      interpreter = DSL::Cache.instance.interpreter_module(api, options)

      DSL::State.new(api, interpreter, Controller::State, options)
    end

    module_function :new
  end

  def meta
    meta_data = {
      version: Logic::Spec[:version],
      api_references: Logic::API[:candidates].values.map do |candidate|
        candidate[:version]
      end,
      interpreters: Logic::Interpreter[:candidates].values.map do |candidate|
        candidate[:version]
      end
    }

    Struct.new(*meta_data.keys).new(*meta_data.values)
  end

  def global
    DSL::Global
  end

  module_function :meta, :global
end
