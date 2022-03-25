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
      def merge_traceback!(ruby_error, lua_traceback)
        ruby_error.set_backtrace(
          ruby_error.backtrace.concat(lua_traceback.split("\n"))
        )

        ruby_error
      end

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

      module_function :for, :merge_traceback!
    end
  end
end
