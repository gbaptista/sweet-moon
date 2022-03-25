require_relative '../../../logic/tables'

require_relative 'writer'
require_relative 'reader'

module Component
  module V54
    Table = {
      create_table!: ->(api, state, list) {
        api.lua_createtable(state[:lua], list.size, 0)
      },

      push!: ->(api, state, component, list, stack_index = -1) {
        stack_index = api.lua_gettop(state[:lua]) if stack_index == -1

        component::Table[:create_table!].(api, state, list)

        if list.is_a? Hash
          list.each_key do |key|
            component::Writer[:push!].(api, state, component, key)
            component::Writer[:push!].(api, state, component, list[key])
            api.lua_settable(state[:lua], stack_index + 1)
          end
        else
          list.each_with_index do |value, index|
            component::Writer[:push!].(api, state, component, index + 1)
            component::Writer[:push!].(api, state, component, value)
            api.lua_settable(state[:lua], stack_index + 1)
          end
        end
      },

      read!: ->(api, state, component, stack_index) {
        stack_index = api.lua_gettop(state[:lua]) if stack_index == -1

        type = api.lua_typename(
          state[:lua], api.lua_type(state[:lua], stack_index)
        ).read_string

        api.lua_pushnil(state[:lua])

        return nil if type != 'table'

        tuples = []

        while api.lua_next(state[:lua], stack_index).positive?
          value = component::Reader[:read!].(api, state, component, stack_index + 2)
          key = component::Reader[:read!].(api, state, component, stack_index + 1)
          api.lua_settop(state[:lua], -2) if value[:pop]

          tuples << [key[:value], value[:value]]

          break if value[:type] == 'no value' || key[:value].instance_of?(Proc)
        end

        { value: Logic::Tables[:to_hash_or_array].(tuples), pop: true }
      },

      read_field!: ->(api, state, _component, expected_key, stack_index) {
        expected_key = expected_key.to_s if expected_key.is_a? Symbol

        api.lua_getfield(state[:lua], stack_index, expected_key)
      }
    }
  end
end
