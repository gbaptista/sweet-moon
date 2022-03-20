module Component
  module V542
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
        },
        lua_pcall: {
          requires: [:lua_pcallk],
          injection: ->(l, n, r, f) { lua_pcallk(l, n, r, f, 0, -1) }
        },
        luaL_loadfile: {
          requires: [:luaL_loadfilex],
          injection: ->(l, f) { luaL_loadfilex(l, f, nil) }
        },
        lua_tonumber: {
          requires: [:lua_tonumberx],
          injection: ->(l, i) { lua_tonumberx(l, i, nil) }
        },
        lua_tointeger: {
          requires: [:lua_tointegerx],
          injection: ->(l, i) { lua_tointegerx(l, i, nil) }
        },
        lua_tostring: {
          requires: [:lua_tolstring],
          injection: ->(l, i) { lua_tolstring(l, i, nil) }
        },
        luaL_typename: {
          requires: %i[lua_typename lua_type],
          injection: ->(l, i) { lua_typename(l, lua_type(l, i)) }
        },
        lua_insert: {
          requires: %i[lua_rotate],
          injection: ->(l, idx) { lua_rotate(l, idx, 1) }
        }
      }
    }
  end
end
