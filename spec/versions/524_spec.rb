require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  context 'api' do
    it do
      config = YAML.load_file('config/tests.yml')

      api = SweetMoon::API.new(shared_object: config['5.2.4']['shared_object'])

      state = api.luaL_newstate
      api.luaL_openlibs(state)

      api.luaL_loadstring(state, 'return math.pow(2, 3);')
      api.lua_pcall(state, 0, 1, 0)

      expect(api.lua_tonumber(state, -1)).to eq(8.0)

      api.lua_pop(state)

      expect(api.lua_close(state)).to eq(nil)
    end
  end

  context 'nil state' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.2.4']['shared_object'])

      expect(state.get('nope')).to eq(nil)
      expect(state.set('a?', 1)).to eq(nil)
      expect(state.get('a?')).to eq(1)

      expect(state.set(:a, 'a  b')).to eq(nil)
      expect(state.get(:a)).to eq('a  b')
    end
  end

  context 'state' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.2.4']['shared_object'])

      expect(state.meta.runtime).to eq('Lua 5.2')
      expect(state.meta.to_h).to eq(
        api_reference: '5.4.2',
        interpreter: '5.4',
        runtime: 'Lua 5.2',
        shared_objects: [config['5.2.4']['shared_object']],
        global_ffi: false
      )
      expect(state.eval('return _VERSION')).to eq('Lua 5.2')

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

      expect(state.get(:lorem)).to eq(nil)
      expect(state.get(:lorem, :a)).to eq(nil)

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

      expect(state.add_package_path(config['5.2.4']['fennel'])).to eq(nil)

      expect(state.fennel.eval('(+ 1 2)')).to eq(3.0)

      expect(state.fennel.set('a/b?', 3)).to eq(nil)
      expect(state.fennel.get('a/b?')).to eq(3.0)
      expect(state.fennel.eval('_G.a/b?')).to eq(3.0)

      expect(state.fennel.eval('(+ 1 2)')).to eq(3.0)
      expect(state.fennel.meta.runtime).to eq('Fennel 1.0.0 on Lua 5.2')
      expect(state.fennel.meta.to_h[:runtime]).to eq('Fennel 1.0.0 on Lua 5.2')

      expect(state.set(:gcSum, ->(a, b) { a + b })).to eq(nil)
      expect(state.eval('return gcSum(1, 2)')).to eq(3.0)
      GC.start
      expect(state.eval('return gcSum(1, 2)')).to eq(3.0)

      expect(state.set(:my, {})).to eq(nil)
      expect(state.set(:my, :a, 2)).to eq(nil)
      expect(state.get(:my, :a)).to eq(2.0)
      expect(state.set(:_G, :gba, 3)).to eq(nil)
      expect(state.get(:_G, :gba)).to eq(3.0)
    end
  end

  context 'errors' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.2.4']['shared_object'])

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
        expect(e.full_message).to match(/in function 'a'/)
        expect(e.full_message).to match(%r{spec/versions/examples/error\.lua:3})
      end

      expect(state.add_package_path(config['fennel-dev'])).to eq(nil)

      expect { state.fennel.load('spec/versions/examples/error.fnl') }.to raise_error(
        SystemStackError, /noooope:aaaaa/
      )

      begin
        state.fennel.load('spec/versions/examples/error.fnl')
      rescue SystemStackError => e
        expect(e.full_message).to match(/in function 'a'/)
        expect(e.full_message).to match(%r{spec/versions/examples/error\.fnl:3})
      end

      expect { state.load('spec/versions/examples/error_b.lua') }.to raise_error(
        SystemStackError, /noooope:ccccc/
      )

      begin
        state.load('spec/versions/examples/error_b.lua')
      rescue SystemStackError => e
        expect(e.full_message).to match(/in function 'c'/)
        expect(e.full_message).to match(%r{spec/versions/examples/error_b\.lua:7})
      end
    end
  end
end
