require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
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
