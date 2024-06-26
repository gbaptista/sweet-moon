require 'ffi'

require_relative 'interpreter'
require_relative 'function'
require_relative 'table'

module Component
  module V54
    Reader = {
      read_all!: ->(api, state, component) {
        (1..api.lua_gettop(state[:lua])).map do
          component::Interpreter[:read_and_pop!].(api, state)[:output]
        end.reverse
      },

      read!: ->(api, state, component, stack_index = -1) {
        stack_index = api.lua_gettop(state[:lua]) if stack_index == -1

        type = api.lua_typename(
          state[:lua], api.lua_type(state[:lua], stack_index)
        ).read_string

        case type
        when 'string'
          component::Reader[:read_string!].(api, state, stack_index)
        when 'number'
          component::Reader[:read_number!].(api, state, stack_index)
        when 'no value'
          { value: nil, pop: true, type: }
        when 'nil'
          { value: nil, pop: true }
        when 'boolean'
          component::Reader[:read_boolean!].(api, state, stack_index)
        when 'table'
          component::Table[:read!].(api, state, component, stack_index)
        when 'function'
          component::Function[:read!].(api, state, component, stack_index)
        else
          # none nil boolean lightuserdata number
          # string table function userdata thread
          { value:
              "#{type}: 0x#{api.lua_topointer(state[:lua], stack_index).address}",
            type:, pop: true }
        end
      },

      read_string!: ->(api, state, stack_index) {
        { value: api.lua_tostring(state[:lua], stack_index).read_string,
          pop: true }
      },

      read_number!: ->(api, state, stack_index) {
        if api.respond_to?(:lua_isinteger) &&
           api.respond_to?(:lua_tointeger) &&
           api.lua_isinteger(state[:lua], stack_index) == 1

          return { value: api.lua_tointeger(state[:lua], stack_index), pop: true }
        end

        { value: api.lua_tonumber(state[:lua], stack_index), pop: true }
      },

      read_boolean!: ->(api, state, stack_index) {
        { value: api.lua_toboolean(state[:lua], stack_index) == 1, pop: true }
      }
    }
  end
end
