module Logic
  module V50
    Interpreter = {
      version: '5.0',

      LUA_REGISTRYINDEX: -10_000,
      LUA_GLOBALSINDEX: -10_001,

      # lua_isinteger lua_pushinteger lua_tointeger
      requires: %i[
        lua_close lua_gettable lua_gettop lua_insert lua_newtable lua_next lua_open
        lua_pcall lua_pushboolean lua_pushcclosure lua_pushnil lua_pushnumber
        lua_pushstring lua_rawgeti lua_settable lua_settop lua_toboolean lua_tonumber
        lua_topointer lua_tostring lua_type lua_typename luaL_loadbuffer luaL_loadfile
        luaL_ref luaopen_base luaopen_io luaopen_math luaopen_string luaopen_table
      ],

      status: {
        1 => :LUA_ERRRUN,
        2 => :LUA_ERRFILE,
        3 => :LUA_ERRSYNTAX,
        4 => :LUA_ERRMEM,
        5 => :LUA_ERRERR
      },

      error: {
        LUA_ERRRUN: :runtime,
        LUA_ERRFILE: :file,
        LUA_ERRSYNTAX: :syntax,
        LUA_ERRMEM: :memory_allocation,
        LUA_ERRERR: :message_handler
      }
    }
  end
end
