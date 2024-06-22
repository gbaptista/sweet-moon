require './logic/signature'

RSpec.describe do
  it do
    expect(Logic::Signature[:extract_from_source].(
             '#define ERRNO_SAVE int olderr = errno; DWORD oldwerr = GetLastError();'
           )).to be_nil

    expect(Logic::Signature[:extract_from_source].(
             '#define lua_getlocaledecpoint()    (localeconv()->decimal_point[0])'
           )).to eq(
             name: 'lua_getlocaledecpoint',
             macro: true,
             input: [],
             source: '#define lua_getlocaledecpoint()    (localeconv()->decimal_point[0])'
           )

    expect(Logic::Signature[:extract_from_header].(
             %{
    #define lua_numbertointeger(n,p) \
      ((n) >= (LUA_NUMBER)(LUA_MININTEGER) && \
       (n) < -(LUA_NUMBER)(LUA_MININTEGER) && \
          (*(p) = (LUA_INTEGER)(n), 1))
    }
           )).to eq(['#define lua_numbertointeger(n,p) ((n) >= (LUA_NUMBER)(LUA_MININTEGER) && (n) < -(LUA_NUMBER)(LUA_MININTEGER) && (*(p) = (LUA_INTEGER)(n), 1))'])

    expect(Logic::Signature[:extract_from_source].(
             %{
    #define lua_numbertointeger(n,p) \
      ((n) >= (LUA_NUMBER)(LUA_MININTEGER) && \
       (n) < -(LUA_NUMBER)(LUA_MININTEGER) && \
          (*(p) = (LUA_INTEGER)(n), 1))
    }
           )).to eq(
             name: 'lua_numbertointeger',
             macro: true,
             input: [{ name: 'n' }, { name: 'p' }],
             source: "\n    #define lua_numbertointeger(n,p)       ((n) >= (LUA_NUMBER)(LUA_MININTEGER) &&        (n) < -(LUA_NUMBER)(LUA_MININTEGER) &&           (*(p) = (LUA_INTEGER)(n), 1))\n    "
           )

    expect(Logic::Signature[:extract_from_source].(
             "  \n  #define lua_pop(L,n)    lua_settop(L, -(n)-1)"
           )).to eq(
             name: 'lua_pop',
             macro: true,
             input: [{ name: 'L' }, { name: 'n' }], source: "  \n  #define lua_pop(L,n)    lua_settop(L, -(n)-1)"
           )

    expect(Logic::Signature[:to_ffi].(
             name: 'luaL_newstate',
             output: { pointer: true, type: 'lua_State', constant: false, primitive: 'lua_State' },
             input: [
               { pointer: false, name: nil, type: 'void', constant: false, primitive: 'void' }
             ],
             source: 'LUALIB_API lua_State *(luaL_newstate) (void);'
           )).to eq([:luaL_newstate, [], :pointer])

    expect(Logic::Signature[:extract_from_source].(
             'LUALIB_API lua_State *(luaL_newstate) (void);'
           )).to eq(
             name: 'luaL_newstate',
             output: { pointer: true, type: 'lua_State', constant: false, primitive: 'lua_State' },
             input: [
               { pointer: false, name: nil, type: 'void', constant: false, primitive: 'void' }
             ],
             source: 'LUALIB_API lua_State *(luaL_newstate) (void);'
           )

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef signed char ls_byte;'
           )).to eq({ primitive: 'char', type: 'ls_byte' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef unsigned char lu_byte;'
           )).to eq({ primitive: 'char', type: 'lu_byte' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef int (*lua_Chunkwriter) (lua_State *L, const void* p, size_t sz, void* ud);'
           )).to eq({ primitive: 'int', type: 'lua_Chunkwriter' })

    expect(Logic::Signature[:extract_from_source].(
             'LUALIB_API char *(luaL_buffinitsize) (lua_State *L, luaL_Buffer *B, size_t sz);'
           )).to eq(
             name: 'luaL_buffinitsize',
             output: { constant: false, pointer: true, primitive: 'char', type: 'char' },
             input: [
               { pointer: true, name: 'L', type: 'lua_State', constant: false, primitive: 'lua_State' },
               { pointer: true, name: 'B', type: 'luaL_Buffer', constant: false, primitive: 'luaL_Buffer' },
               { pointer: false, name: 'sz', type: 'size_t', constant: false, primitive: 'size_t' }
             ],
             source: 'LUALIB_API char *(luaL_buffinitsize) (lua_State *L, luaL_Buffer *B, size_t sz);'
           )

    expect(Logic::Signature[:extract_from_source].(
             'LUA_API int   (lua_pcallk) (lua_State *L, int nargs, int nresults, int errfunc, lua_KContext ctx, lua_KFunction k);'
           )).to eq(
             name: 'lua_pcallk',
             output: { pointer: false, type: 'int', constant: false, primitive: 'int' },
             input: [
               { pointer: true, name: 'L', type: 'lua_State', constant: false, primitive: 'lua_State' },
               { pointer: false, name: 'nargs', type: 'int', constant: false, primitive: 'int' },
               { pointer: false, name: 'nresults', type: 'int', constant: false, primitive: 'int' },
               { pointer: false, name: 'errfunc', type: 'int', constant: false, primitive: 'int' },
               { pointer: false, name: 'ctx', type: 'lua_KContext', constant: false, primitive: 'lua_KContext' },
               { pointer: false, name: 'k', type: 'lua_KFunction', constant: false, primitive: 'lua_KFunction' }
             ],
             source: 'LUA_API int   (lua_pcallk) (lua_State *L, int nargs, int nresults, int errfunc, lua_KContext ctx, lua_KFunction k);'
           )

    expect(Logic::Signature[:to_ffi].(
             { name: 'lua_pcall',
               output: { pointer: false, type: 'int', constant: false,
                         primitive: 'int' },
               input: [{ pointer: true,
                         name: 'L',
                         type: 'lua_State',
                         constant: false,
                         primitive: 'struct' },
                       { pointer: false,
                         name: 'nargs',
                         type: 'int',
                         constant: false,
                         primitive: 'int' },
                       { pointer: false,
                         name: 'nresults',
                         type: 'int',
                         constant: false,
                         primitive: 'int' },
                       { pointer: false,
                         name: 'errfunc',
                         type: 'int',
                         constant: false,
                         primitive: 'int' }],
               source: 'LUA_API int lua_pcall (lua_State *L, int nargs, int nresults, int errfunc);' }
           )).to eq([:lua_pcall, %i[pointer int int int], :int])

    expect(Logic::Signature[:to_ffi].(
             { name: 'lua_pushnumber',
               output: { pointer: false, type: 'void', constant: false,
                         primitive: 'void' },
               input: [{ pointer: true,
                         name: 'L',
                         type: 'lua_State',
                         constant: false,
                         primitive: 'struct' },
                       { pointer: false,
                         name: 'n',
                         type: 'lua_Number',
                         constant: false,
                         primitive: 'LUA_NUMBER' }],
               source: 'LUA_API void lua_pushnumber (lua_State *L, lua_Number n);' }
           )).to eq([:lua_pushnumber, %i[pointer double], :void])

    expect(Logic::Signature[:extract_types_from_header].(
             'typedef struct Token {  ' \
             'int token;  ' \
             'SemInfo seminfo;' \
             '} Token;'
           )).to eq({ 'Token' => 'struct' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef int StkId'
           )).to eq({ primitive: 'int', type: 'StkId' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef  LUA_NUM_TYPE real;'
           )).to eq({ primitive: 'LUA_NUM_TYPE', type: 'real' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef enum UnOpr { OPR_MINUS, OPR_NOT, OPR_NOUNOPR } UnOpr;'
           )).to eq({ primitive: 'enum', type: 'UnOpr' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef unsigned int lua_Object;'
           )).to eq({ primitive: 'int', type: 'lua_Object' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef enum {'
           )).to be_nil

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef   int (*lua_CFunction) (lua_State *L);'
           )).to eq({ primitive: 'int', type: 'lua_CFunction' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef const char * (*lua_Chunkreader) (lua_State *L, void *ud, size_t *sz);'
           )).to eq({ primitive: 'char', type: 'lua_Chunkreader' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef  LUA_NUM_TYPE real;'
           )).to eq({ primitive: 'LUA_NUM_TYPE', type: 'real' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef struct lua_Debug lua_Debug;'
           )).to eq({ primitive: 'struct', type: 'lua_Debug' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef struct TaggedString {'
           )).to eq({ primitive: 'struct', type: 'TaggedString' })

    expect(Logic::Signature[:extract_type_from_source].(
             'typedef void (*lua_CFunction) (void);'
           )).to eq({ primitive: 'void', type: 'lua_CFunction' })

    expect(Logic::Signature[:parse_parameter].(
             'lua_State *L'
           )).to eq({ name: 'L', type: 'lua_State', primitive: 'lua_State', pointer: true, constant: false })

    expect(Logic::Signature[:parse_parameter].(
             'const TObject *p1'
           )).to eq({ name: 'p1', type: 'TObject', primitive: 'TObject', pointer: true, constant: true })

    expect(Logic::Signature[:parse_parameter].(
             'const char *const _list[]'
           )).to eq({ constant: true, name: '_list[]', pointer: true, primitive: 'char', type: 'char' })

    expect(Logic::Signature[:extract_from_source].(
             'LUALIB_API int luaL_findstring (const char *name, const char *const _list[]);'
           )).to eq(
             name: 'luaL_findstring',
             output: { pointer: false, type: 'int', constant: false, primitive: 'int' },
             input: [
               { pointer: true, name: 'name', type: 'char', constant: true, primitive: 'char' },
               { pointer: true, name: '_list[]', type: 'char', constant: true, primitive: 'char' }
             ],
             source: 'LUALIB_API int luaL_findstring (const char *name, const char *const _list[]);'
           )

    expect(Logic::Signature[:extract_from_source].(
             'LUA_API const char *lua_version (void);'
           )).to eq(
             name: 'lua_version',
             output: { pointer: true, type: 'char', constant: true, primitive: 'char' },
             input: [
               { pointer: false, name: nil, type: 'void', constant: false, primitive: 'void' }
             ],
             source: 'LUA_API const char *lua_version (void);'
           )

    expect(Logic::Signature[:extract_from_source].(
             '    luaL_argerror(L, numarg,extramsg)'
           )).to be_nil

    expect(Logic::Signature[:extract_from_source].(
             'void luaG_aritherror (lua_State *L, const TObject *p1, const TObject *p2);'
           )).to eq(
             name: 'luaG_aritherror',
             output: { constant: false, pointer: false, type: 'void', primitive: 'void' },
             input: [
               { pointer: true, name: 'L', type: 'lua_State', primitive: 'lua_State', constant: false },
               { pointer: true, name: 'p1', type: 'TObject', primitive: 'TObject', constant: true },
               { pointer: true, name: 'p2', type: 'TObject', primitive: 'TObject', constant: true }
             ],
             source: 'void luaG_aritherror (lua_State *L, const TObject *p1, const TObject *p2);'
           )

    expect(Logic::Signature[:extract_from_source].(
             'const char *luaO_pushfstring (lua_State *L, const char *fmt, ...);'
           )).to eq(
             name: 'luaO_pushfstring',
             output: { constant: true, pointer: true, type: 'char', primitive: 'char' },
             input: [
               { pointer: true, name: 'L', type: 'lua_State', primitive: 'lua_State', constant: false },
               { pointer: true, name: 'fmt', type: 'char', primitive: 'char', constant: true },
               { pointer: false, name: nil, type: 'va_list', primitive: 'va_list', constant: false }
             ],
             source: 'const char *luaO_pushfstring (lua_State *L, const char *fmt, ...);'
           )

    expect(Logic::Signature[:extract_from_source].(
             'LUA_API int lua_yield (lua_State *L, int nresults);'
           )).to eq(
             name: 'lua_yield',
             output: { pointer: false, type: 'int', primitive: 'int', constant: false },
             input: [
               { pointer: true, name: 'L', type: 'lua_State', primitive: 'lua_State', constant: false },
               { pointer: false, name: 'nresults', type: 'int', primitive: 'int', constant: false }
             ],
             source: 'LUA_API int lua_yield (lua_State *L, int nresults);'
           )

    expect(Logic::Signature[:extract_from_source].(
             'LUA_API const char *lua_typename (lua_State *L, int tp);'
           )).to eq(
             name: 'lua_typename',
             output: { pointer: true, type: 'char', primitive: 'char', constant: true },
             input: [
               { pointer: true, name: 'L', type: 'lua_State', primitive: 'lua_State', constant: false },
               { pointer: false, name: 'tp', type: 'int', primitive: 'int', constant: false }
             ],
             source: 'LUA_API const char *lua_typename (lua_State *L, int tp);'
           )

    expect(Logic::Signature[:extract_from_source].(
             'Proto* luaU_undump (lua_State* L, ZIO* Z, Mbuffer* buff);'
           )).to eq(
             name: 'luaU_undump',
             output: { pointer: true, type: 'Proto', primitive: 'Proto', constant: false },
             input: [
               { pointer: true, name: 'L', type: 'lua_State', primitive: 'lua_State', constant: false },
               { pointer: true, name: 'Z', type: 'ZIO', primitive: 'ZIO', constant: false },
               { pointer: true, name: 'buff', type: 'Mbuffer', primitive: 'Mbuffer', constant: false }
             ],
             source: 'Proto* luaU_undump (lua_State* L, ZIO* Z, Mbuffer* buff);'
           )

    expect(Logic::Signature[:extract_from_source].(
             'Proto* luaU_undump (lua_State* L, ZIO* Z, Mbuffer* buff);',
             { 'lua_State' => 'lorem', 'lorem' => 'int', 'Proto' => 'string' }
           )).to eq(
             name: 'luaU_undump',
             output: { pointer: true, type: 'Proto', constant: false, primitive: 'string' },
             input: [
               { pointer: true, name: 'L', type: 'lua_State', constant: false, primitive: 'int' },
               { pointer: true, name: 'Z', type: 'ZIO', constant: false, primitive: 'ZIO' },
               { pointer: true, name: 'buff', type: 'Mbuffer', constant: false, primitive: 'Mbuffer' }
             ],
             source: 'Proto* luaU_undump (lua_State* L, ZIO* Z, Mbuffer* buff);'
           )

    expect(Logic::Signature[:extract_from_nm].(
             "00000000000097d0 T lua_cpcall\n" \
             "000000000000cbb0 T luaD_call\n" \
             '000000000000c590 T luaD_callhook'
           )).to eq %w[luaD_call luaD_callhook lua_cpcall]

    expect(
      Logic::Signature[:extract_from_header].(
        "LUA_API int   lua_gettop (lua_State\n    *L);\n" \
        'LUA_API void  lua_settop (lua_State *L  , int idx);'
      )
    ).to eq(
      ['LUA_API int lua_gettop (lua_State *L);',
       'LUA_API void lua_settop (lua_State *L , int idx);']
    )
  end
end
