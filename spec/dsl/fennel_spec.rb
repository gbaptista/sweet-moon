require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  context 'local Fennel' do
    it do
      config = YAML.load_file('config/tests.yml')

      lua = SweetMoon::State.new(
        shared_object: config['5.4.2']['shared_object'],
        package_path: config['5.4.2']['fennel']
      )

      fennel = lua.fennel

      expect(fennel.meta.to_h).to eq(
        shared_objects: [config['5.4.2']['shared_object']],
        api_reference: '5.4.2',
        interpreter: '5.4',
        runtime: 'Fennel 1.0.0 on Lua 5.4'
      )

      expect(fennel.eval('(+ 1 1)')).to eq(2)
      expect(fennel.eval('(global fl 3)')).to eq(nil)
      expect(fennel.get(:fl)).to eq(3)

      expect(fennel.load('spec/dsl/examples/read.fnl')).to eq({ 'b' => 2 })

      expect(fennel.get(:a)).to eq(1)

      expect(fennel.meta.to_h).to eq(
        api_reference: '5.4.2',
        interpreter: '5.4',
        runtime: 'Fennel 1.0.0 on Lua 5.4',
        shared_objects: [config['5.4.2']['shared_object']]
      )

      expect(fennel.meta.api_reference).to eq('5.4.2')
      expect(fennel.meta.interpreter).to eq('5.4')
      expect(fennel.meta.runtime).to eq('Fennel 1.0.0 on Lua 5.4')
      expect(fennel.meta.shared_objects).to eq(
        [config['5.4.2']['shared_object']]
      )
    end
  end

  context 'global Fennel' do
    it do
      config = YAML.load_file('config/tests.yml')

      SweetMoon.global.clear

      SweetMoon.global.config(
        shared_object: config['5.4.2']['shared_object'],
        package_path: config['5.4.2']['fennel']
      )

      fennel = SweetMoon.global.state.fennel

      expect(fennel.meta.to_h).to eq(
        shared_objects: [config['5.4.2']['shared_object']],
        api_reference: '5.4.2',
        interpreter: '5.4',
        runtime: 'Fennel 1.0.0 on Lua 5.4'
      )

      expect(fennel.eval('(+ 1 1)')).to eq(2)
      expect(fennel.eval('(global fl 3)')).to eq(nil)
      expect(fennel.get(:fl)).to eq(3)

      expect(fennel.load('spec/dsl/examples/read.fnl')).to eq({ 'b' => 2 })

      expect(fennel.get(:a)).to eq(1)

      expect(fennel.meta.to_h).to eq(
        api_reference: '5.4.2',
        interpreter: '5.4',
        runtime: 'Fennel 1.0.0 on Lua 5.4',
        shared_objects: [config['5.4.2']['shared_object']]
      )

      expect(fennel.meta.api_reference).to eq('5.4.2')
      expect(fennel.meta.interpreter).to eq('5.4')
      expect(fennel.meta.runtime).to eq('Fennel 1.0.0 on Lua 5.4')
      expect(fennel.meta.shared_objects).to eq(
        [config['5.4.2']['shared_object']]
      )
    end
  end
end
