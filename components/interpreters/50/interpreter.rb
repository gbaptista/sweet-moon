require_relative '../../../logic/interpreters/interpreter_50'

require_relative 'reader'
require_relative 'writer'
require_relative 'table'

module Component
  module V50
    Interpreter = {
      version: Logic::V50::Interpreter[:version],

      create_state!: ->(api) {
        state = api.lua_open
        { state: { lua: state, avoid_gc: [] },
          error: state ? nil : :MemoryAllocation }
      },

      open_standard_libraries!: ->(api, state) {
        api.luaopen_base(state[:lua])
        api.luaopen_table(state[:lua])
        api.luaopen_io(state[:lua])
        api.luaopen_string(state[:lua])
        api.luaopen_math(state[:lua])

        api.lua_settop(state[:lua], -7 - 1)

        { state: state }
      },

      load_file_and_push_chunck!: ->(api, state, path) {
        result = api.luaL_loadfile(state[:lua], path)
        { state: state, error: Interpreter[:_error].(api, state, result, pull: true) }
      },

      push_chunk!: ->(api, state, value) {
        result = api.luaL_loadbuffer(state[:lua], value, value.size, value)

        { state: state, error: Interpreter[:_error].(api, state, result, pull: true) }
      },

      set_table!: ->(api, state, variable, value) {
        Table[:set!].(api, state, variable, value)
      },

      push_value!: ->(api, state, value) {
        Writer[:push!].(api, state, value)
        { state: state }
      },

      pop_and_set_as!: ->(api, state, variable) {
        api.lua_pushstring(state[:lua], variable)
        api.lua_insert(state[:lua], -2)
        api.lua_settable(state[:lua], Logic::V50::Interpreter[:LUA_GLOBALSINDEX])
        { state: state }
      },

      get_variable_and_push!: ->(api, state, variable, key = nil) {
        api.lua_pushstring(state[:lua], variable.to_s)
        api.lua_gettable(state[:lua], Logic::V50::Interpreter[:LUA_GLOBALSINDEX])

        Table[:read_field_and_push!].(api, state, key, -1) unless key.nil?

        { state: state }
      },

      call!: ->(api, state, inputs = 0, outputs = 1) {
        result = api.lua_pcall(state[:lua], inputs, outputs, 0)
        { state: state, error: Interpreter[:_error].(api, state, result, pull: true) }
      },

      read_and_pop!: ->(api, state, stack_index = -1, extra_pop: false) {
        result = Component::V50::Reader[:read!].(api, state, stack_index)

        api.lua_settop(state[:lua], -2) if result[:pop]
        api.lua_settop(state[:lua], -2) if extra_pop

        { state: state, output: result[:value] }
      },

      read_all!: ->(api, state) {
        result = Reader[:read_all!].(api, state)

        { state: state, output: result }
      },

      destroy_state!: ->(api, state) {
        result = api.lua_close(state[:lua])

        state.delete(:lua)
        state.delete(:avoid_gc)

        { state: nil, error: Interpreter[:_error].(api, nil, result) }
      },

      _error: ->(api, state, code, options = {}) {
        status = Logic::V50::Interpreter[:error][
          Logic::V50::Interpreter[:status][code]
        ] || :error

        if code.is_a?(Numeric) && code >= 1
          return { status: status } unless options[:pull] && state

          { status: status,
            value: Interpreter[:read_and_pop!].(api, state, -1)[:output] }
        end
      }
    }
  end
end
