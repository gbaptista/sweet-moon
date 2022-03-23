require 'yaml'

require './dsl/sweet_moon'

RSpec.describe 'Lua 4.0.1' do
  context 'api', skip: true do
    it do
      config = YAML.load_file('config/tests.yml')

      api = SweetMoon::API.new(shared_objects: config['4.0.1']['shared_objects'])

      # #define LUA_MINSTACK 20
      # #define BASIC_STACK_SIZE (2*LUA_MINSTACK)
      # If stacksize is zero, then a default size of 1024 is used.
      state = api.lua_open(0)

      api.lua_baselibopen(state)
      api.lua_strlibopen(state)
      api.lua_mathlibopen(state)
      api.lua_iolibopen(state)

      api.lua_dostring(state, 'return 2 ^ 3')

      expect(api.lua_tonumber(state, -1)).to eq(8.0)

      api.lua_settop(state, -1 - 1)

      expect(api.lua_close(state)).to eq(nil)
    end
  end

  context 'state', skip: true do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_objects: config['4.0.1']['shared_objects'])

      expect(state.eval('return "a  b"')).to eq('a  b')
      expect(state.eval('return 2')).to eq(2)

      expect { state.eval('return 1 + true') }.to raise_error(
        SweetMoon::Errors::LuaRuntimeError,
        '[string "return 1 + true"]:1: attempt to perform arithmetic on a boolean value'
      )

      expect(state.eval('return 1.5')).to eq(1.5)
      expect(state.eval('return true')).to eq(true)
      expect(state.eval('return false')).to eq(false)
      expect(state.eval('return nil')).to eq(nil)

      expect(state.eval('return {"a", "b", {"c", "d"}}')).to eq(['a', 'b', %w[c d]])
      expect(state.eval('return {}')).to eq({})

      expect(state.eval('return {a = 1, b = true, c = {d = 2}}')).to eq(
        { 'a' => 1.0, 'b' => true, 'c' => { 'd' => 2.0 } }
      )

      expect(state.set(:a, 'a  b')).to eq(nil)
      expect(state.set(:b, 2)).to eq(nil)
      expect(state.set(:c, 1.5)).to eq(nil)
      expect(state.set(:d, true)).to eq(nil)
      expect(state.set(:e, false)).to eq(nil)
      expect(state.set(:f, nil)).to eq(nil)

      expect(state.set(:g, ['a', 'b', %w[c d]])).to eq(nil)
      expect(state.set(:h, [])).to eq(nil)
      expect(state.set(:i, {})).to eq(nil)
      expect(
        state.set(:j, { 'a' => 1.0, 'b' => true, 'c' => { 'd' => 2.0 } })
      ).to eq(nil)

      expect(state.get(:a)).to eq('a  b')
      expect(state.get(:b)).to eq(2)
      expect(state.get(:c)).to eq(1.5)
      expect(state.get(:d)).to eq(true)
      expect(state.get(:e)).to eq(false)
      expect(state.get(:f)).to eq(nil)

      expect(state.get(:g)).to eq(['a', 'b', %w[c d]])
      expect(state.get(:h)).to eq({})
      expect(state.get(:i)).to eq({})
      expect(state.get(:j)).to eq({ 'a' => 1.0, 'b' => true, 'c' => { 'd' => 2.0 } })

      expect(state.get(:j, :b)).to eq(true)

      expect(state.eval('return j["c"]["d"]')).to eq(2.0)

      expect(state.eval('lua_fn = function(a, b) return "ok", a + b; end')).to eq(nil)

      lua_fn = state.get(:lua_fn)

      expect(lua_fn.call([1, 2])).to eq('ok')
      expect(lua_fn.call([1, 2], 2)).to eq(['ok', 3.0])

      sum_list = ->(list) { list.sum }

      expect(state.set('sumList', sum_list)).to eq(nil)

      expect(state.eval('return sumList({2, 3, 5})')).to eq(10.0)

      expect(state.load('spec/versions/examples/read.lua')).to eq({ 'a' => 3.0 })
      expect(state.get(:color)).to eq({ 'blue' => false, 'green' => 23.4, 'red' => 45.0 })

      expect { state.add_package_path('/?.lua') }.to raise_error(
        SweetMoon::Errors::SweetMoonError, 'package.path requires Lua >= 5.1'
      )

      expect(state.set(:gcSum, ->(a, b) { a + b })).to eq(nil)
      expect(state.eval('return gcSum(1, 2)')).to eq(3.0)
      GC.start
      expect(state.eval('return gcSum(1, 2)')).to eq(3.0)
    end
  end
end
