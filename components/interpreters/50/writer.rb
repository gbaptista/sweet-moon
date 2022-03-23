require_relative 'function'
require_relative 'table'

module Component
  module V50
    Writer = {
      push!: ->(api, state, value) {
        case Writer[:_to_lua_type].(value)
        when 'string'
          api.lua_pushstring(state[:lua], value.to_s)
        when 'number'
          api.lua_pushnumber(state[:lua], value)
        when 'integer'
          if api.respond_to? :lua_pushinteger
            api.lua_pushinteger(state[:lua], value)
          else
            api.lua_pushnumber(state[:lua], value)
          end
        when 'nil'
          api.lua_pushnil(state[:lua])
        when 'boolean'
          api.lua_pushboolean(state[:lua], value ? 1 : 0)
        when 'table'
          Table[:push!].(api, state, value)
        when 'function'
          Function[:push!].(api, state, value)
        else
          api.lua_pushstring(
            state[:lua], "#<#{value.class}:0x#{format('%016x', value.object_id)}>"
          )
        end
      },

      _to_lua_type: ->(value) {
        return 'nil' if value.nil?
        return 'function' if value.is_a?(Proc)
        return 'integer' if value.is_a? Integer
        return 'number' if value.is_a? Float
        return 'table' if value.is_a?(Hash) || value.is_a?(Array)
        return 'string' if value.is_a?(String) || value.instance_of?(Symbol)
        return 'boolean' if [true, false].include? value
      }
    }
  end
end
