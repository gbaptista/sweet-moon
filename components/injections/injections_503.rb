module Component
  module V503
    Injections = {
      callbacks: [
        {
          ffi: [:cfunction, [:pointer], :int],
          overwrite: {
            lua_pushcclosure: [%i[pointer cfunction int], :void],
            lua_tocfunction: [%i[pointer int], :cfunction]
          }
        }
      ],
      macros: {
        lua_pop: {
          requires: [:lua_settop],
          injection: ->(l, n = 1) { lua_settop(l, -n - 1) }
        }
      }
    }
  end
end
