module Logic
  module V54
    Interpreter = {
      version: '5.4',

      LUA_RIDX_GLOBALS: 2,

      # TODO: It's possible to read C constants?
      # LUAI_MAXSTACK = 1_000_000
      # -LUAI_MAXSTACK - 1000
      LUA_REGISTRYINDEX: -1_000_000 - 1000,

      # lua_isinteger lua_pushinteger lua_tointeger
      requires: %i[
        lua_close lua_createtable lua_getfield lua_gettop lua_next lua_pcall
        lua_pushboolean lua_pushcclosure lua_pushnil lua_pushnumber lua_pushstring
        lua_rawgeti lua_settable lua_settop lua_toboolean lua_tonumber lua_topointer
        lua_tostring lua_type lua_typename luaL_loadfile luaL_loadstring luaL_newstate
        luaL_openlibs luaL_ref lua_getglobal lua_setglobal
      ],

      status: {
        0 => :LUA_OK,
        1 => :LUA_YIELD,
        2 => :LUA_ERRRUN,
        3 => :LUA_ERRSYNTAX,
        4 => :LUA_ERRMEM,
        5 => :LUA_ERRERR,
        6 => :LUA_ERRFILE
      },

      error: {
        LUA_ERRRUN: :runtime,
        LUA_ERRSYNTAX: :syntax,
        LUA_ERRMEM: :memory_allocation,
        LUA_ERRERR: :message_handler,
        LUA_ERRFILE: :file
      }
    }
  end
end
