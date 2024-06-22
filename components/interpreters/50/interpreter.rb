require_relative '../../../logic/interpreters/interpreter_50'

require_relative 'function'
require_relative 'reader'
require_relative 'table'
require_relative 'writer'

module Component
  module V50
    Interpreter = {
      version: Logic::V50::Interpreter[:version],
      logic: Logic::V50,

      create_state!: ->(api) {
        state = api.lua_open
        { state: { lua: state, avoid_gc: [], ruby_error_info: nil },
          error: state ? nil : :MemoryAllocation }
      },

      open_standard_libraries!: ->(api, state) {
        api.luaopen_base(state[:lua])
        api.luaopen_table(state[:lua])
        api.luaopen_io(state[:lua])
        api.luaopen_string(state[:lua])
        api.luaopen_math(state[:lua])

        api.lua_settop(state[:lua], -7 - 1)

        { state: }
      },

      load_file_and_push_chunck!: ->(api, state, path) {
        result = api.luaL_loadfile(state[:lua], path)
        { state:, error: Interpreter[:_error].(api, state, result, pull: true) }
      },

      push_chunk!: ->(api, state, value) {
        result = api.luaL_loadbuffer(state[:lua], value, value.size, value)

        { state:, error: Interpreter[:_error].(api, state, result, pull: true) }
      },

      set_table!: ->(api, state) {
        result = api.lua_settable(state[:lua], -3)

        api.lua_settop(state[:lua], -2)

        { state:,
          error: Interpreter[:_error].(api, state, result, pull: false) }
      },

      push_value!: ->(api, state, value) {
        Writer[:push!].(api, state, Component::V50, value)
        { state: }
      },

      pop_and_set_as!: ->(api, state, variable) {
        api.lua_pushstring(state[:lua], variable)
        api.lua_insert(state[:lua], -2)
        api.lua_settable(state[:lua], Logic::V50::Interpreter[:LUA_GLOBALSINDEX])
        { state: }
      },

      get_variable_and_push!: ->(api, state, variable, key = nil) {
        extra_pop = true
        if variable == '_G'
          variable = key
          key = nil
          extra_pop = false
        end

        api.lua_pushstring(state[:lua], variable.to_s)
        api.lua_gettable(state[:lua], Logic::V50::Interpreter[:LUA_GLOBALSINDEX])

        unless key.nil?
          Table[:read_field_and_push!].(api, state, Component::V50, key,
                                        -1)
        end

        { state:, extra_pop: }
      },

      call!: ->(api, state, inputs = 0, outputs = 1) {
        result = api.lua_pcall(state[:lua], inputs, outputs, 0)
        { state:, error: Interpreter[:_error].(api, state, result, pull: true) }
      },

      read_and_pop!: ->(api, state, stack_index = -1, extra_pop: false) {
        result = Component::V50::Reader[:read!].(api, state, Component::V50,
                                                 stack_index)

        api.lua_settop(state[:lua], -2) if result[:pop]
        api.lua_settop(state[:lua], -2) if extra_pop

        { state:, output: result[:value] }
      },

      read_all!: ->(api, state) {
        result = Reader[:read_all!].(api, state, Component::V50)

        { state:, output: result }
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
          return { status: } unless options[:pull] && state

          { status:,
            value: Interpreter[:read_and_pop!].(api, state, -1)[:output] }
        end
      }
    }
  end
end
