require 'yaml'

require './controllers/api'
require './controllers/state'
require './controllers/interpreter'

require './dsl/state'

RSpec.describe do
  context '5.4.4' do
    before do
      config = YAML.load_file('config/tests.yml')['5.4.4']

      options = { shared_object: config['shared_object'] }

      api = Controller::API[:handle!].(options)
      interpreter = Controller::Interpreter[:handle!].(api, options)

      @state = DSL::State.new(api, interpreter, Controller::State)
    end

    context 'load, eval and read' do
      it do
        expect(@state.eval('return _VERSION;')).to eq('Lua 5.4')
        expect(@state.eval('return 1.5 + 1.5;')).to eq(3.0)

        expect(@state.load('spec/dsl/examples/read.lua')).to eq({ 'a' => 3 })

        expect(@state.get('width')).to eq(200)
        expect(@state.get('height')).to eq(1.5)
        expect(@state.get('depth')).to eq(true)
        expect(@state.get('name')).to eq('config lua')
        expect(@state.get('empty')).to eq(nil)
        expect(@state.get('color')).to eq(
          { 'blue' => false, 'green' => 23.4, 'red' => 45 }
        )

        expect(@state.get('lorem')).to eq(nil)

        expect(@state.eval('lorem = "spec amet";')).to eq(nil)

        expect(@state.get('lorem')).to eq('spec amet')

        expect(@state.eval('lorem = "spec2";')).to eq(nil)

        expect(@state.get('lorem')).to eq('spec2')

        expect(@state.destroy).to eq(nil)

        expect { @state.eval('return 1.5 + 1.5;') }.to raise_error(
          SweetMoon::Errors::SweetMoonError, /state no longer exists/
        )

        expect { @state.load('spec/dsl/examples/read.lua') }.to raise_error(
          SweetMoon::Errors::SweetMoonError, /state no longer exists/
        )

        expect { expect(@state.get('name')).to eq('config') }.to raise_error(
          SweetMoon::Errors::SweetMoonError, /state no longer exists/
        )
      end
    end

    context 'write' do
      it do
        expect(@state.get('a')).to eq(nil)

        expect(@state.set('a', 200)).to eq(nil)
        expect(@state.get('a')).to eq(200)

        expect(@state.set('b', 1.5)).to eq(nil)
        expect(@state.get('b')).to eq(1.5)
        expect(@state.eval('return b')).to eq(1.5)

        expect(@state.set('c', true)).to eq(nil)
        expect(@state.get('c')).to eq(true)

        expect(@state.set('d', false)).to eq(nil)
        expect(@state.get('d')).to eq(false)

        expect(@state.set('e', nil)).to eq(nil)
        expect(@state.get('e')).to eq(nil)

        expect(@state.set('f', 'lorem ipsum')).to eq(nil)
        expect(@state.get('f')).to eq('lorem ipsum')

        expect(@state.set('h', :amet)).to eq(nil)
        expect(@state.get('h')).to eq('amet')

        expect(@state.load('spec/dsl/examples/write.lua')).to eq(
          { 'a' => 200, 'b' => 1.5, 'c' => true, 'd' => false, 'f' => 'lorem ipsum' }
        )
      end
    end

    context 'functions and lambdas' do
      it do
        expect(@state.set('rubyFn', ->(a, b) { a + b })).to eq(nil)

        expect(@state.eval('return rubyFn(1.2, 2);')).to eq(3.2)

        expect(@state.eval('function luaFn(a, b) return a + b; end')).to eq(nil)

        expect(@state.eval('return luaFn(1.2, 2.1);')).to eq(3.3)

        lua_fn = @state.get('luaFn')
        expect(lua_fn.class).to eq(Proc)

        expect(lua_fn.([1, 2])).to eq(3)
        expect(lua_fn.([1, 2], 2)).to eq([3, nil])
        expect(lua_fn.([1.2, 2.1])).to eq(3.3)

        expect(lua_fn.([1.2, '1'])).to eq(2.2)

        expect { lua_fn.([1.2, 'A']) }.to raise_error(
          SweetMoon::Errors::LuaRuntimeError, /add a 'number' with a 'string'/
        )

        expect(@state.eval('return 1 + 1;')).to eq(2)

        file = "#{Time.now.to_i}-xpto.lua"

        expect(@state.eval("return io.open('#{file}')", 3)).to eq(
          [nil, "#{file}: No such file or directory", 2]
        )
      end
    end

    context 'tables, arrays and hashes' do
      it do
        expect(@state.eval('return {"a", "b", "c"};')).to eq(%w[a b c])

        expect(@state.eval('return {};')).to eq({})

        expect(@state.eval(
                 'return {a = 1, b = { l = "k", m = "j", o = {}}, c = "a"};'
               )).to eq(
                 { 'a' => 1, 'b' => { 'l' => 'k', 'm' => 'j', 'o' => {} }, 'c' => 'a' }
               )

        expect(@state.set(
                 'a',
                 { a: 'b', c: true, d: { e: 'f', g: { h: 1.5, i: 6 } }, j: 1.5 }
               )).to eq(nil)

        expect(@state.eval('return 1.5 + 1.5;')).to eq(3.0)

        expect(@state.get('a')).to eq(
          { 'a' => 'b', 'c' => true,
            'd' => { 'e' => 'f', 'g' => { 'h' => 1.5, 'i' => 6 } },
            'j' => 1.5 }
        )

        expect(@state.set('b', ['a', 1, [2, 3, 4], { a: ['c', :d] }, '5'])).to eq(nil)

        expect(@state.eval('return 1.5 + 1.5;')).to eq(3.0)

        expect(@state.get('b')).to eq(['a', 1, [2, 3, 4], { 'a' => %w[c d] }, '5'])

        expect(@state.eval('return 1.5 + 1.5;')).to eq(3.0)

        expect(@state.set('rubyFn', ->(list) { list.join(',') })).to eq(nil)
        expect(@state.eval('return 1.5 + 1.5;')).to eq(3.0)
        expect(@state.eval(
                 'function luaFn(list) return "ok", table.concat(list, ",") ; end'
               )).to eq(nil)
        expect(@state.eval('return 1.5 + 1.5;')).to eq(3.0)

        expect(@state.eval('return rubyFn({"a", "b"});')).to eq('a,b')
        expect(@state.eval('return 1.5 + 1.5;')).to eq(3.0)
        expect(@state.eval('return luaFn({"a", "b"});', 2)).to eq(['ok', 'a,b'])
        expect(@state.eval('return 1.5 + 1.5;')).to eq(3.0)

        lua_fn = @state.get('luaFn')
        expect(lua_fn.class).to eq(Proc)

        expect(@state.eval('return 1.5 + 1.5;')).to eq(3.0)
        expect(lua_fn.([%w[a b c]], 2)).to eq(['ok', 'a,b,c'])
        expect(@state.eval('return 1.5 + 1.5;')).to eq(3.0)

        ruby_fn = @state.get('rubyFn')
        expect(ruby_fn.class).to eq(Proc)

        expect(ruby_fn.([%w[a b c]])).to eq('a,b,c')

        expect(@state.set('subFn', [{ a: ->(c, d) { c + d } }])).to eq(nil)

        expect(@state.get('subFn').first['a'].([2, 3])).to eq(5)

        expect(
          @state.eval(
            'subLuaFn = {a = 1, b = function(l) return table.concat(l, ",") ; end}'
          )
        ).to eq(nil)

        expect(@state.eval('return 1.5 + 1.5;')).to eq(3.0)

        sub_lua_fn = @state.get('subLuaFn')

        expect(sub_lua_fn.keys.sort).to match(%w[a b])
        expect(sub_lua_fn['b'].([%w[c d]])).to eq('c,d')
      end
    end

    context 'other types' do
      it do
        expect(@state.eval('a = coroutine.create(function() end)')).to eq(nil)
        expect(@state.get(:a)).to match(/^thread: 0x\d+$/)

        expect(@state.set(:b, Thread.new { 1 + 1 })).to eq(nil)
        expect(@state.get('b')).to match(/^#<Thread:0x.+>$/)

        expect(@state.eval('b = { c = coroutine.create(function() end) }')).to eq(nil)

        expect(@state.get(:b).keys).to eq(['c'])
        expect(@state.get(:b)['c']).to match(/^thread: 0x\d+$/)

        expect(@state.set(:c, { d: Thread.new { 1 + 1 } })).to eq(nil)
        expect(@state.get('c').keys).to eq(['d'])
        expect(@state.get('c')['d']).to match(/^#<Thread:0x.+>$/)
        expect(@state.eval('return 1 + 2')).to eq(3)
      end
    end
  end
end
