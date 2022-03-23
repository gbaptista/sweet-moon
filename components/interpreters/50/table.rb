require_relative '../../../logic/tables'

require_relative 'writer'
require_relative 'reader'

module Component
  module V50
    Table = {
      push!: ->(api, state, list, stack_index = -1) {
        stack_index = api.lua_gettop(state[:lua]) if stack_index == -1

        api.lua_newtable(state[:lua])

        if list.is_a? Hash
          list.each_key do |key|
            Writer[:push!].(api, state, key)
            Writer[:push!].(api, state, list[key])
            api.lua_settable(state[:lua], stack_index + 1)
          end
        else
          list.each_with_index do |value, index|
            Writer[:push!].(api, state, index + 1)
            Writer[:push!].(api, state, value)
            api.lua_settable(state[:lua], stack_index + 1)
          end
        end
      },

      read!: ->(api, state, stack_index) {
        stack_index = api.lua_gettop(state[:lua]) if stack_index == -1

        type = api.lua_typename(state[:lua],
                                api.lua_type(state[:lua], stack_index)).read_string

        api.lua_pushnil(state[:lua])

        return nil if type != 'table'

        tuples = []

        while api.lua_next(state[:lua], stack_index).positive?
          value = Reader[:read!].(api, state, stack_index + 2)
          key = Reader[:read!].(api, state, stack_index + 1)
          api.lua_settop(state[:lua], -2) if value[:pop]

          tuples << [key[:value], value[:value]]

          break if value[:type] == 'no value'
        end

        { value: Logic::Tables[:to_hash_or_array].(tuples), pop: true }
      },

      read_field_and_push!: ->(api, state, expected_key, stack_index) {
        stack_index = api.lua_gettop(state[:lua]) if stack_index == -1

        type = api.lua_typename(state[:lua],
                                api.lua_type(state[:lua], stack_index)).read_string

        api.lua_pushnil(state[:lua])

        return nil if type != 'table'

        result = nil

        while api.lua_next(state[:lua], stack_index).positive?
          value = Reader[:read!].(api, state, stack_index + 2)
          key = Reader[:read!].(api, state, stack_index + 1)

          api.lua_settop(state[:lua], -2) if value[:pop]

          key_type = api.lua_typename(
            state[:lua], api.lua_type(state[:lua], stack_index + 1)
          ).read_string

          if Table[:is_same_key].(key_type, key[:value], expected_key)
            result = value[:value]
            break
          end

          break if value[:type] == 'no value'
        end

        api.lua_settop(state[:lua], -2)

        Writer[:push!].(api, state, result)
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
