require_relative '../../../logic/interpreters/interpreter_54'

require_relative 'function'
require_relative 'reader'
require_relative 'table'
require_relative 'writer'

module Component
  module V54
    Interpreter = {
      version: Logic::V54::Interpreter[:version],
      logic: Logic::V54,

      create_state!: ->(api) {
        state = api.luaL_newstate
        { state: { lua: state, avoid_gc: [], ruby_error_info: nil },
          error: state ? nil : :MemoryAllocation }
      },

      open_standard_libraries!: ->(api, state) {
        api.luaL_openlibs(state[:lua])
        { state: }
      },

      load_file_and_push_chunck!: ->(api, state, path) {
        result = api.luaL_loadfile(state[:lua], path)
        { state:, error: Interpreter[:_error].(api, state, result, pull: true) }
      },

      push_chunk!: ->(api, state, value) {
        result = api.luaL_loadstring(state[:lua], value)
        { state:, error: Interpreter[:_error].(api, state, result, pull: true) }
      },

      set_table!: ->(api, state) {
        result = api.lua_settable(state[:lua], -3)

        api.lua_settop(state[:lua], -2)

        { state:,
          error: Interpreter[:_error].(api, state, result, pull: false) }
      },

      push_value!: ->(api, state, value) {
        Writer[:push!].(api, state, Component::V54, value)
        { state: }
      },

      pop_and_set_as!: ->(api, state, variable) {
        api.lua_setglobal(state[:lua], variable)
        { state: }
      },

      get_variable_and_push!: ->(api, state, variable, key = nil) {
        api.lua_getglobal(state[:lua], variable.to_s)

        unless key.nil?
          if api.lua_typename(state[:lua],
                              api.lua_type(state[:lua], -1)).read_string == 'table'
            Table[:read_field!].(api, state, Component::V54, key, -1)
          else
            api.lua_pushnil(state[:lua])
          end
        end

        { state:, extra_pop: true }
      },

      call!: ->(api, state, inputs = 0, outputs = 1) {
        result = api.lua_pcall(state[:lua], inputs, outputs, 0)
        { state:, error: Interpreter[:_error].(api, state, result, pull: true) }
      },

      read_and_pop!: ->(api, state, stack_index = -1, extra_pop: false) {
        result = Component::V54::Reader[:read!].(api, state, Component::V54,
                                                 stack_index)

        api.lua_settop(state[:lua], -2) if result[:pop]
        api.lua_settop(state[:lua], -2) if extra_pop

        { state:, output: result[:value] }
      },

      read_all!: ->(api, state) {
        result = Reader[:read_all!].(api, state, Component::V54)

        { state:, output: result }
      },

      destroy_state!: ->(api, state) {
        result = api.lua_close(state[:lua])

        state.delete(:lua)
        state.delete(:avoid_gc)

        { state: nil, error: Interpreter[:_error].(api, nil, result) }
      },

      _error: ->(api, state, code, options = {}) {
        status = Logic::V54::Interpreter[:error][
          Logic::V54::Interpreter[:status][code]
        ] || :error

        if code.is_a?(Numeric) && code >= 2
          return { status: } unless options[:pull] && state

          { status:,
            value: Interpreter[:read_and_pop!].(api, state, -1)[:output] }
        end
      }
    }
  end
end
