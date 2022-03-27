require_relative '../54/function'

module Component
  module V50
    Function = Component::V54::Function

    LUA_HANDLER = <<~LUA
      return function (...)
        result = _ruby(unpack(arg))

        if result['error'] then
          error(result['output'])
        else
          return result['output']
        end
      end
    LUA
  end
end
