require_relative '../dsl/errors'

module Controller
  State = {
    create!: ->(api, interpreter) {
      result = State[:_check!].(interpreter[:create_state!].(api))
      result = State[:_check!].(
        interpreter[:open_standard_libraries!].(api, result[:state])
      )

      { state: result[:state] }
    },

    eval!: ->(api, interpreter, state, input, outputs = 1) {
      result = State[:_check!].(interpreter[:push_chunk!].(api, state, input))

      State[:_call_and_read!].(api, interpreter, result[:state], outputs)
    },

    load!: ->(api, interpreter, state, path, outputs = 1) {
      result = State[:_check!].(
        interpreter[:load_file_and_push_chunck!].(api, state, path)
      )

      State[:_call_and_read!].(api, interpreter, result[:state], outputs)
    },

    get!: ->(api, interpreter, state, variable, key = nil) {
      if key.nil?
        key = variable
        variable = '_G'
      end

      State[:_get_key!].(api, interpreter, state, variable, key)
    },

    _get_key!: ->(api, interpreter, state, variable, key) {
      result = State[:_check!].(
        interpreter[:get_variable_and_push!].(api, state, variable, key)
      )

      result = State[:_check!].(
        interpreter[:read_and_pop!].(
          api, result[:state], -1, extra_pop: result[:extra_pop]
        )
      )

      { state: result[:state], output: result[:output] }
    },

    set!: ->(api, interpreter, state, variable, key_or_value, value = nil) {
      if value.nil?
        result = State[:_check!].(interpreter[:push_value!].(api, state,
                                                             key_or_value))

        result = State[:_check!].(
          interpreter[:pop_and_set_as!].(api, result[:state], variable.to_s)
        )
      else
        result = State[:_check!].(
          interpreter[:get_variable_and_push!].(api, state, variable)
        )

        result = State[:_check!].(interpreter[:push_value!].(api, result[:state],
                                                             key_or_value))
        result = State[:_check!].(interpreter[:push_value!].(api, result[:state],
                                                             value))

        result = State[:_check!].(interpreter[:set_table!].(api, result[:state]))
      end

      { state: result[:state], output: result[:output] }
    },

    destroy!: ->(api, interpreter, state) {
      State[:_check!].(interpreter[:destroy_state!].(api, state))

      { state: nil }
    },

    _call_and_read!: ->(api, interpreter, state, outputs = 1) {
      result = State[:_check!].(interpreter[:call!].(api, state, 0, outputs))
      result = State[:_check!].(interpreter[:read_all!].(api, result[:state]))

      { state: result[:state],
        output: outputs <= 1 ? result[:output].first : result[:output] }
    },

    _check!: ->(result) {
      if result[:error]
        raise SweetMoon::Errors::SweetMoonErrorHelper.for(
          result[:error][:status]
        ), result[:error][:value]
      end

      result
    }
  }
end
