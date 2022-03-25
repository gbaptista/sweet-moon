module Component
  module V514
    Injections = {
      callbacks: [
        {
          ffi: [:cfunction, [:pointer], :int],
          overwrite: {
            lua_pushcclosure: [%i[pointer cfunction int], :void],
            lua_tocfunction: [%i[pointer int], :cfunction],
            lua_atpanic: [%i[pointer cfunction], :cfunction]
          }
        }
      ],
      macros: {
        lua_pop: {
          requires: [:lua_settop],
          injection: ->(l, n = 1) { lua_settop(l, -n - 1) }
        },
        lua_tostring: {
          requires: [:lua_tolstring],
          injection: ->(l, i) { lua_tolstring(l, i, nil) }
        },
        luaL_typename: {
          requires: %i[lua_typename lua_type],
          injection: ->(l, i) { lua_typename(l, lua_type(l, i)) }
        }
      }
    }
  end
end
