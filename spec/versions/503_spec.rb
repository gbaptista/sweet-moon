require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  context 'api' do
    it do
      config = YAML.load_file('config/tests.yml')

      api = SweetMoon::API.new(shared_object: config['5.0.3']['shared_object'])

      state = api.lua_open

      api.luaopen_base(state)
      api.luaopen_table(state)
      api.luaopen_io(state)
      api.luaopen_string(state)
      api.luaopen_math(state)

      input = 'return math.pow(2, 3);'
      api.luaL_loadbuffer(state, input, input.size, input)

      api.lua_pcall(state, 0, 1, 0)

      expect(api.lua_tonumber(state, -1)).to eq(8.0)

      api.lua_settop(state, -1 - 1)

      expect(api.lua_close(state)).to be_nil
    end
  end

  context 'nil state' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.0.3']['shared_object'])

      expect(state.get('nope')).to be_nil
      expect(state.set('a?', 1)).to be_nil
      expect(state.get('a?')).to eq(1)

      expect(state.set(:a, 'a  b')).to be_nil
      expect(state.get(:a)).to eq('a  b')
    end
  end

  context 'function' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.0.3']['shared_object'])

      sum_list = lambda(&:sum)

      expect(state.set('sumList', sum_list)).to be_nil

      expect(state.eval('return sumList({2, 3, 5})')).to eq(10.0)
    end
  end

  context 'state' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.0.3']['shared_object'])

      expect(state.meta.runtime).to eq('Lua 5.0.3')
      expect(state.meta.to_h).to eq(
        api_reference: '5.0.3',
        interpreter: '5.0',
        runtime: 'Lua 5.0.3',
        shared_objects: [config['5.0.3']['shared_object']],
        global_ffi: false
      )

      expect(state.eval('return _VERSION')).to eq('Lua 5.0.3')

      expect(state.eval('return "a  b"')).to eq('a  b')
      expect(state.eval('return 2')).to eq(2)

      expect { state.eval('return 1 + true') }.to raise_error(
        SweetMoon::Errors::LuaRuntimeError,
        '[string "return 1 + true"]:1: attempt to perform arithmetic on a boolean value'
      )

      expect(state.eval('return 1.5')).to eq(1.5)
      expect(state.eval('return true')).to be(true)
      expect(state.eval('return false')).to be(false)
      expect(state.eval('return nil')).to be_nil

      expect(state.eval('return {"a", "b", {"c", "d"}}')).to eq(['a', 'b', %w[c d]])
      expect(state.eval('return {}')).to eq({})

      expect(state.eval('return {a = 1, b = true, c = {d = 2}}')).to eq(
        { 'a' => 1.0, 'b' => true, 'c' => { 'd' => 2.0 } }
      )

      expect(state.set(:a, 'a  b')).to be_nil
      expect(state.set(:b, 2)).to be_nil
      expect(state.set(:c, 1.5)).to be_nil
      expect(state.set(:d, true)).to be_nil
      expect(state.set(:e, false)).to be_nil
      expect(state.set(:f, nil)).to be_nil

      expect(state.set(:g, ['a', 'b', %w[c d]])).to be_nil
      expect(state.set(:h, [])).to be_nil
      expect(state.set(:i, {})).to be_nil
      expect(
        state.set(:j, { 'a' => 1.0, 'b' => true, 'c' => { 'd' => 2.0 } })
      ).to be_nil

      expect(state.get(:lorem)).to be_nil
      expect(state.get(:lorem, :a)).to be_nil

      expect(state.get(:a)).to eq('a  b')
      expect(state.get(:b)).to eq(2)
      expect(state.get(:c)).to eq(1.5)
      expect(state.get(:d)).to be(true)
      expect(state.get(:e)).to be(false)
      expect(state.get(:f)).to be_nil

      expect(state.get(:g)).to eq(['a', 'b', %w[c d]])
      expect(state.get(:h)).to eq({})
      expect(state.get(:i)).to eq({})
      expect(state.get(:j)).to eq({ 'a' => 1.0, 'b' => true, 'c' => { 'd' => 2.0 } })

      expect(state.get(:j, :b)).to be(true)

      expect(state.eval('return j["c"]["d"]')).to eq(2.0)

      expect(state.eval('lua_fn = function(a, b) return "ok", a + b; end')).to be_nil

      lua_fn = state.get(:lua_fn)

      expect(lua_fn.call([1, 2])).to eq('ok')
      expect(lua_fn.call([1, 2], 2)).to eq(['ok', 3.0])

      sum_list = lambda(&:sum)

      expect(state.set('sumList', sum_list)).to be_nil

      expect(state.eval('return sumList({2, 3, 5})')).to eq(10.0)

      expect(state.load('spec/versions/examples/read.lua')).to eq({ 'a' => 3.0 })
      expect(state.get(:color)).to eq({ 'blue' => false, 'green' => 23.4, 'red' => 45.0 })

      expect { state.add_package_path('/?.lua') }.to raise_error(
        SweetMoon::Errors::SweetMoonError,
        'package.path requires Lua >= 5.1 or LuaJIT >= 2; Current: Lua 5.0.3 (5.0)'
      )

      expect(state.set(:gcSum, ->(a, b) { a + b })).to be_nil
      expect(state.eval('return gcSum(1, 2)')).to eq(3.0)
      GC.start
      expect(state.eval('return gcSum(1, 2)')).to eq(3.0)

      expect(state.set(:my, {})).to be_nil
      expect(state.set(:my, :a, 2)).to be_nil
      expect(state.get(:my, :a)).to eq(2.0)
      expect(state.set(:_G, :gba, 3)).to be_nil
      expect(state.get(:_G, :gba)).to eq(3.0)
    end
  end

  context 'errors' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.0.3']['shared_object'])

      state.set('a', -> { raise SystemStackError, 'noooope:aaaaa' })
      state.set('b', -> { 1 })
      state.set('c', -> { raise SystemStackError, 'noooope:ccccc' })
      state.set('d', -> { 1 })

      expect { state.load('spec/versions/examples/error.lua') }.to raise_error(
        SystemStackError, /noooope:aaaaa/
      )

      begin
        state.load('spec/versions/examples/error.lua')
      rescue SystemStackError => e
        expect(e.full_message).to match(/return function \(...\)/)
      end

      expect { state.load('spec/versions/examples/error_b.lua') }.to raise_error(
        SystemStackError, /noooope:ccccc/
      )

      begin
        state.load('spec/versions/examples/error_b.lua')
      rescue SystemStackError => e
        expect(e.full_message).to match(/return function \(...\)/)
      end
    end
  end
end
