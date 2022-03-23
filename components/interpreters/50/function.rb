require_relative '../../../logic/interpreters/interpreter_50'
require_relative '../../../dsl/errors'

require_relative 'writer'
require_relative 'reader'

module Component
  module V50
    Function = {
      push!: ->(api, state, closure) {
        handler = ->(current_state) {
          updated_state = state.merge(lua: current_state)
          input = Reader[:read_all!].(api, updated_state)
          result = closure.(*input)
          Writer[:push!].(api, updated_state, result)
          return 1
        }

        state[:avoid_gc] << handler

        api.lua_pushcclosure(state[:lua], handler, 0)
      },

      read!: ->(api, state, _stack_index) {
        reference = api.luaL_ref(
          state[:lua], Logic::V50::Interpreter[:LUA_REGISTRYINDEX]
        )

        { value: ->(input = [], output = 1) {
          api.lua_rawgeti(
            state[:lua], Logic::V50::Interpreter[:LUA_REGISTRYINDEX], reference
          )

          input.each do |value|
            Writer[:push!].(api, state, value)
          end

          result = Interpreter[:call!].(api, state, input.size, output)

          if result[:error]
            raise SweetMoon::Errors::SweetMoonErrorHelper.for(
              result[:error][:status]
            ), result[:error][:value]
          end

          result = Reader[:read_all!].(api, state)

          return result.first if output == 1

          result
        }, pop: false }
      }
    }
  end
end
