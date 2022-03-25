require_relative '../../../logic/tables'

require_relative 'writer'
require_relative 'reader'

module Component
  module V50
    Table = {
      create_table!: ->(api, state, _list) {
        api.lua_newtable(state[:lua])
      },

      push!: Component::V54::Table[:push!],
      read!: Component::V54::Table[:read!],

      read_field_and_push!: ->(api, state, component, expected_key, stack_index) {
        stack_index = api.lua_gettop(state[:lua]) if stack_index == -1

        type = api.lua_typename(
          state[:lua], api.lua_type(state[:lua], stack_index)
        ).read_string

        api.lua_pushnil(state[:lua])

        return nil if type != 'table'

        result = nil

        while api.lua_next(state[:lua], stack_index).positive?
          value = component::Reader[:read!].(api, state, component, stack_index + 2)
          key = component::Reader[:read!].(api, state, component, stack_index + 1)

          api.lua_settop(state[:lua], -2) if value[:pop]

          key_type = api.lua_typename(
            state[:lua], api.lua_type(state[:lua], stack_index + 1)
          ).read_string

          if component::Table[:is_same_key].(key_type, key[:value], expected_key)
            result = value[:value]
            break
          end

          break if value[:type] == 'no value' || key[:value].instance_of?(Proc)
        end

        api.lua_settop(state[:lua], -2)

        component::Writer[:push!].(api, state, component, result)
      },

      is_same_key: ->(lua_key_type, lua_key, ruby_key) {
        lua_key == case lua_key_type
                   when 'string'
                     ruby_key.to_s
                   when 'number'
                     ruby_key.to_f
                   else
                     ruby_key
                   end
      }
    }
  end
end
