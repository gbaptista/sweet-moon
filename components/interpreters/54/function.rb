require_relative '../../../logic/interpreters/interpreter_54'
require_relative '../../../dsl/errors'

require_relative 'interpreter'
require_relative 'reader'
require_relative 'writer'

module Component
  module V54
    Function = {
      push!: ->(api, state, component, closure) {
        handler = component::Function[:build_handler!].(
          api, state, component, closure
        )

        state[:avoid_gc] << handler

        lua_name = "_sweet_moon_ruby_#{handler.object_id}"

        api.lua_pushcclosure(state[:lua], handler, 0)
        component::Interpreter[:pop_and_set_as!].(api, state, lua_name)

        result = component::Interpreter[:push_chunk!].(
          api, state, component::LUA_HANDLER.sub('_ruby', lua_name)
        )

        unless result[:error].nil?
          raise SweetMoon::Errors::SweetMoonErrorHelper.for(
            result[:error][:status]
          ), result[:error][:value]
        end

        component::Interpreter[:call!].(api, state, 0, 1)
      },

      build_handler!: ->(api, state, component, closure) {
        ->(current_state) {
          updated_state = state.merge(lua: current_state)
          input = component::Reader[:read_all!].(api, updated_state, component)
          begin
            result = closure.(*input)
            component::Writer[:push!].(
              api, updated_state, component, { error: nil, output: result }
            )
          rescue Exception => e
            state[:ruby_error_info] = e
            component::Writer[:push!].(
              api, updated_state, component, {
                error: true, output: "#{e.class}: #{e.message}"
              }
            )
          end
          1
        }
      },

      read!: ->(api, state, component, _stack_index) {
        lua_registry_index = component::Interpreter[:logic]::Interpreter[
          :LUA_REGISTRYINDEX
        ]

        reference = api.luaL_ref(state[:lua], lua_registry_index)

        { value: ->(input = [], output = 1) {
          api.lua_rawgeti(state[:lua], lua_registry_index, reference)

          input.each do |value|
            component::Writer[:push!].(api, state, component, value)
          end

          result = component::Interpreter[:call!].(api, state, input.size, output)

          component::Function[:raise_error!].(state, result) if result[:error]

          result = component::Reader[:read_all!].(api, state, component)

          return result.first if output == 1

          result
        }, pop: false }
      },

      raise_error!: ->(state, result) {
        if state[:ruby_error_info].nil?
          raise SweetMoon::Errors::SweetMoonErrorHelper.for(
            result[:error][:status]
          ), result[:error][:value]
        else
          ruby_error = state[:ruby_error_info]
          state[:ruby_error_info] = nil

          raise SweetMoon::Errors::SweetMoonErrorHelper.merge_traceback!(
            ruby_error, result[:error][:value]
          )
        end
      }
    }

    LUA_HANDLER = <<~LUA
      return function (...)
        result = _ruby(...)

        if result['error'] then
          error(result['output'] .. ' ' .. debug.traceback())
        else
          return result['output']
        end
      end
    LUA
  end
end
