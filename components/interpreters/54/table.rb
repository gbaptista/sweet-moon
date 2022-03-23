require_relative '../../../logic/tables'

require_relative 'writer'
require_relative 'reader'

module Component
  module V54
    Table = {
      push!: ->(api, state, list, stack_index = -1) {
        stack_index = api.lua_gettop(state[:lua]) if stack_index == -1

        api.lua_createtable(state[:lua], list.size, 0)

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

          break if value[:type] == 'no value' || key[:value].instance_of?(Proc)
        end

        { value: Logic::Tables[:to_hash_or_array].(tuples), pop: true }
      },

      read_field!: ->(api, state, expected_key, stack_index) {
        expected_key = expected_key.to_s if expected_key.is_a? Symbol

        api.lua_getfield(state[:lua], stack_index, expected_key)
      }
    }
  end
end
