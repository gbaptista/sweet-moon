require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  context 'meta' do
    it do
      expect(SweetMoon.meta.version).to eq('0.0.7')
      expect(SweetMoon.meta.api_references).to eq(['3.2.2', '4.0.1', '5.0.3', '5.1.4', '5.4.2'])
      expect(SweetMoon.meta.interpreters).to eq(['5.0', '5.1', '5.4'])

      expect(SweetMoon.meta.to_h).to eq(
        version: '0.0.7',
        api_references: ['3.2.2', '4.0.1', '5.0.3', '5.1.4', '5.4.2'],
        interpreters: ['5.0', '5.1', '5.4']
      )
    end
  end

  context 'local state' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.4.4']['shared_object'])

      expect(state.meta.to_h).to eq(
        api_reference: '5.4.2', interpreter: '5.4', runtime: 'Lua 5.4',
        shared_objects: [config['5.4.4']['shared_object']],
        global_ffi: false
      )

      expect(state.meta.api_reference).to eq('5.4.2')
      expect(state.meta.interpreter).to eq('5.4')
      expect(state.meta.runtime).to eq('Lua 5.4')
      expect(state.meta.shared_objects).to eq([config['5.4.4']['shared_object']])

      expect(state.eval('return 1.5 + 1.5;')).to eq(3.0)

      state_b = SweetMoon::State.new(shared_object: config['5.4.2']['shared_object'])

      expect(state_b.meta.to_h).to eq(
        api_reference: '5.4.2', interpreter: '5.4', runtime: 'Lua 5.4',
        shared_objects: [config['5.4.2']['shared_object']],
        global_ffi: false
      )

      expect(state.eval('return 1.5 + 1.5;')).to eq(3.0)
    end
  end

  context 'local api' do
    it do
      expect(SweetMoon.meta.version).to eq('0.0.7')

      config = YAML.load_file('config/tests.yml')

      api = SweetMoon::API.new(shared_object: config['5.4.4']['shared_object'])

      expect(api.functions.size).to be > 150
      expect(api.signature_for(:luaL_gsub).keys).to eq(%i[source input output])
      expect(api.signature_for(:luaH_new)).to be_nil

      expect(api.meta.to_h).to eq(
        api_reference: '5.4.2', shared_objects: [config['5.4.4']['shared_object']],
        global_ffi: false
      )

      api_b = SweetMoon::API.new(shared_object: config['3.2.2']['shared_object'])

      expect(api_b.meta.to_h).to eq(
        api_reference: '3.2.2', shared_objects: [config['3.2.2']['shared_object']],
        global_ffi: false
      )

      expect(api_b.functions.size).to be > 150
      expect(api_b.signature_for(:luaL_gsub)).to be_nil
      expect(api_b.signature_for(:luaH_new).keys).to eq(%i[source input output])
    end
  end

  context 'global api' do
    it do
      SweetMoon.global.clear

      expect(SweetMoon.meta.version).to eq('0.0.7')

      config = YAML.load_file('config/tests.yml')

      expect(SweetMoon.global.cached).to eq([])

      SweetMoon.global.config(shared_object: config['5.4.4']['shared_object'])

      expect(SweetMoon.global.cached).to eq(%i[global_api_module global_api])

      expect(SweetMoon.global.api.meta.to_h).to eq(
        api_reference: '5.4.2', shared_objects: [config['5.4.4']['shared_object']],
        global_ffi: false
      )

      expect(SweetMoon.global.api.functions.size).to be > 150
      expect(SweetMoon.global.api.signature_for(:luaL_gsub).keys).to eq(
        %i[source input output]
      )

      SweetMoon.global.config(shared_object: config['3.2.2']['shared_object'])

      expect(SweetMoon.global.api.meta.to_h).to eq(
        api_reference: '3.2.2', shared_objects: [config['3.2.2']['shared_object']],
        global_ffi: false
      )

      expect(SweetMoon.global.api.functions.size).to be > 150
      expect(SweetMoon.global.api.signature_for(:luaL_gsub)).to be_nil
    end
  end

  context 'global state' do
    it do
      config = YAML.load_file('config/tests.yml')

      SweetMoon.global.clear

      expect(SweetMoon.meta.version).to eq('0.0.7')

      SweetMoon.global.config(shared_object: config['5.4.4']['shared_object'])

      expect(SweetMoon.global.state.eval('return 1 + 2')).to eq(3)
      expect(SweetMoon.global.state.eval('value = "a b"')).to be_nil
      expect(SweetMoon.global.state.get(:value)).to eq('a b')

      SweetMoon.global.config(shared_object: config['5.4.4']['shared_object'])

      expect(SweetMoon.global.state.get(:value)).to be_nil

      expect(SweetMoon.global.state.eval('return 1 + 2')).to eq(3)

      expect(SweetMoon.global.state.eval('value = "a b"')).to be_nil
      expect(SweetMoon.global.state.get(:value)).to eq('a b')

      SweetMoon.global.config

      expect(SweetMoon.global.state.get(:value)).to eq('a b')

      SweetMoon.global.config(interpreter: '5.4')

      expect(SweetMoon.global.state.get(:value)).to be_nil

      expect(SweetMoon.global.state.eval('return 1 + 1')).to eq(2)

      expect(SweetMoon.global.state.eval('value = "a b"')).to be_nil
      expect(SweetMoon.global.state.get(:value)).to eq('a b')

      expect(SweetMoon.global.state.clear).to be_nil

      expect(SweetMoon.global.state.get(:value)).to be_nil
      expect(SweetMoon.global.state.eval('value = "a b"')).to be_nil
    end
  end
end
