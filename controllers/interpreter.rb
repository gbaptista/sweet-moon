require_relative '../components/interpreters'
require_relative '../logic/interpreter'
require_relative 'state'
require_relative '../dsl/errors'

module Controller
  Interpreter = {
    handle!: ->(api, options = {}) {
      component = {}

      component[:interpreter] = Interpreter[:elect_interpreter!].(
        api, options
      )

      component = Interpreter[:build_meta!].(component, options)
      component = Interpreter[:build_runtime!].(api, component, options)

      component
    },

    build_meta!: ->(component, options) {
      component[:meta] = {
        options: options,
        elected: {
          interpreter: component[:interpreter][:version]
        },
        runtime: {}
      }

      component
    },

    build_runtime!: ->(api, component, _options) {
      state = State[:create!].(api[:api], component[:interpreter])[:state]

      result = State[:eval!].(
        api[:api], component[:interpreter], state, 'return _VERSION;'
      )

      is_jit = State[:get!].(
        api[:api], component[:interpreter], state, 'jit', 'version'
      )[:output]

      State[:destroy!].(api[:api], component[:interpreter], state)

      component[:meta][:runtime][:lua] = if is_jit
                                           "#{is_jit} (#{result[:output]})"
                                         else
                                           result[:output]
                                         end

      component
    },

    elect_interpreter!: ->(api, options) {
      result = Logic::Interpreter[:elect].(
        api[:signatures], api[:meta][:elected][:api_reference], options
      )

      unless result[:compatible]
        raise SweetMoon::Errors::SweetMoonError,
              result[:error]
      end

      return Component::Interpreters[result[:version]][:interpreter]
    }
  }
end
