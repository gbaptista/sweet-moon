require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  context 'multi values' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(
        shared_object: config['5.4.4']['shared_object']
      )

      expect(state.meta.to_h).to eq(
        shared_objects: [config['5.4.4']['shared_object']],
        api_reference: '5.4.2',
        interpreter: '5.4',
        runtime: 'Lua 5.4',
        global_ffi: false
      )

      expect(state.eval('return "a", "b"', 2)).to eq(%w[a b])
      expect(state.eval('return "a", "b"', 1)).to eq('a')

      expect(state.eval('return "a", "b"', { outputs: 2 })).to eq(%w[a b])

      expect(state.eval('return "a", "b"', { outputs: 1 })).to eq('a')

      expect(state.load('spec/dsl/examples/values.lua')).to eq('a')
      expect(state.load('spec/dsl/examples/values.lua', 2)).to eq(%w[a b])

      expect(
        state.load('spec/dsl/examples/values.lua', { outputs: 2 })
      ).to eq(%w[a b])
    end
  end

  context 'lambdas' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(
        shared_object: config['5.4.4']['shared_object']
      )

      ruby_fn = lambda do |a, b|
        return a + b
      end

      sum_list = ->(list) { list.sum }

      state.set(:rubyFn, ruby_fn) # => nil
      state.set(:sumList, sum_list) # => nil

      expect(state.eval('return rubyFn(2, 2)')).to eq(4)
      expect(state.eval('return sumList({2, 3, 5})')).to eq(10)

      expect(state.eval('return sumList({2, 3, 5})')).to eq(10)
      expect(state.eval('return rubyFn(2, 2)')).to eq(4)

      expect(state.eval('return rubyFn(2, 2)')).to eq(4)
      expect(state.eval('return sumList({2, 3, 5})')).to eq(10)
    end
  end

  context 'lambdas' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(
        shared_object: config['5.4.4']['shared_object']
      )

      state.eval('second = function(list) return list[2]; end')

      second = state.get('second')

      expect(second.([%w[a b c]], 1)).to eq('b')
    end
  end
end
