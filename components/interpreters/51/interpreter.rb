require_relative '../../../logic/interpreters/interpreter_51'

require_relative 'reader'
require_relative 'writer'
require_relative 'table'

module Component
  module V51
    Interpreter = {
      version: Logic::V51::Interpreter[:version],

      create_state!: ->(api) {
        state = api.luaL_newstate
        { state: state, error: state ? nil : :MemoryAllocation }
      },

      open_standard_libraries!: ->(api, state) {
        api.luaL_openlibs(state)

        { state: state }
      },

      load_file_and_push_chunck!: ->(api, state, path) {
        result = api.luaL_loadfile(state, path)
        { state: state, error: Interpreter[:_error].(api, state, result, pull: true) }
      },

      push_chunk!: ->(api, state, value) {
        result = api.luaL_loadstring(state, value)
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
        api.lua_pushstring(state, variable)
        api.lua_insert(state, -2)
        api.lua_settable(state, Logic::V51::Interpreter[:LUA_GLOBALSINDEX])
        { state: state }
      },

      get_variable_and_push!: ->(api, state, variable, key = nil) {
        api.lua_pushstring(state, variable.to_s)
        api.lua_gettable(state, Logic::V51::Interpreter[:LUA_GLOBALSINDEX])

        unless key.nil?
          if api.lua_typename(state, api.lua_type(state, -1)).read_string == 'table'
            Table[:read_field!].(api, state, key, -1)
          else
            api.lua_pushnil(state)
          end
        end

        { state: state }
      },

      call!: ->(api, state, inputs = 0, outputs = 1) {
        result = api.lua_pcall(state, inputs, outputs, 0)
        { state: state, error: Interpreter[:_error].(api, state, result, pull: true) }
      },

      read_and_pop!: ->(api, state, stack_index = -1, extra_pop: false) {
        result = Component::V51::Reader[:read!].(api, state, stack_index)

        api.lua_settop(state, -2) if result[:pop]
        api.lua_settop(state, -2) if extra_pop

        { state: state, output: result[:value] }
      },

      read_all!: ->(api, state) {
        result = Reader[:read_all!].(api, state)

        { state: state, output: result }
      },

      destroy_state!: ->(api, state) {
        result = api.lua_close(state)

        { state: nil, error: Interpreter[:_error].(api, state, result) }
      },

      _error: ->(api, state, code, options = {}) {
        status = Logic::V51::Interpreter[:error][
          Logic::V51::Interpreter[:status][code]
        ] || :error

        if code.is_a?(Numeric) && code >= 2
          return { status: status } unless options[:pull]

          { status: status,
            value: Interpreter[:read_and_pop!].(api, state, -1)[:output] }
        end
      }
    }
  end
end
