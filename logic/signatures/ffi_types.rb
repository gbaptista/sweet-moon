# https://github.com/ffi/ffi/wiki/Types#types

module Logic
  module Signatures
    FFITypes = {
      char: 'char',
      double: 'double',
      int: 'int',
      long: 'long',
      LUA_INTEGER: 'int',
      LUA_KCONTEXT: 'int',
      LUA_NUMBER: 'double',
      LUA_UNSIGNED: 'uint',
      ptrdiff_t: 'int',
      size_t: 'ulong',
      va_list: 'varargs',
      void: 'void',
      enum: 'int', # TODO
      struct: 'int', # TODO
      TObject: 'int', # TODO

      # Lua Jit:
      short: 'int', # TODO
      unsigned: 'int' # TODO
    }
  end
end
