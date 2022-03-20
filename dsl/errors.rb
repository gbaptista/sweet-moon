module SweetMoon
  module Errors
    class SweetMoonError < StandardError; end
    class LuaError < SweetMoonError; end

    class LuaRuntimeError < LuaError; end
    class LuaMemoryAllocationError < LuaError; end
    class LuaMessageHandlerError < LuaError; end
    class LuaSyntaxError < LuaError; end
    class LuaFileError < LuaError; end

    module SweetMoonErrorHelper
      def for(status)
        case status
        when :runtime           then LuaRuntimeError
        when :memory_allocation then LuaMemoryAllocationError
        when :message_handler   then LuaMessageHandlerError
        when :syntax            then LuaSyntaxError
        when :file              then LuaFileError
        else
          LuaError
        end
      end

      module_function :for
    end
  end
end
