require 'yaml'

require './controllers/api'
require './dsl/api'

RSpec.describe do
  context '5.4.4' do
    it do
      config = YAML.load_file('config/tests.yml')['5.4.4']

      component = Controller::API[:handle!].(shared_objects: [config['shared_object']])

      api = DSL::Api.new(component)

      expect(api.meta.to_h).to eq(
        shared_objects: [config['shared_object']], api_reference: '5.4.2',
        global_ffi: false
      )

      expect(api.functions.size).to be > 150

      expect(api.functions).to include(:luaL_newstate)

      expect(api.signature_for(:luaL_newstate).keys).to eq(%i[source input output])
      expect(api.signature_for('luaL_newstate').keys).to eq(%i[source input output])
      expect(api.signature_for(:lua_setstate)).to eq(nil)

      expect(api.respond_to?(:luaL_newstate)).to eq(true)
      expect(api.respond_to?(:lua_setstate)).to eq(false)
    end
  end

  context '3.2.2' do
    it do
      config = YAML.load_file('config/tests.yml')['3.2.2']

      component = Controller::API[:handle!].(shared_objects: [config['shared_object']])

      api = DSL::Api.new(component)

      expect(api.meta.to_h).to eq(
        shared_objects: [config['shared_object']], api_reference: '3.2.2',
        global_ffi: false
      )

      expect(api.functions.size).to be > 150

      expect(api.functions).to include(:lua_setstate)

      expect(api.signature_for(:luaL_newstate)).to eq(nil)

      expect(api.signature_for(:lua_setstate).keys).to eq(%i[source input output])
      expect(api.signature_for('lua_setstate').keys).to eq(%i[source input output])

      expect(api.respond_to?(:lua_setstate)).to eq(true)
      expect(api.respond_to?(:luaL_newstate)).to eq(false)
    end
  end

  context '5.4.4 Flow' do
    it do
      config = YAML.load_file('config/tests.yml')['5.4.4']

      api = DSL::Api.new(
        Controller::API[:handle!].(shared_objects: [config['shared_object']])
      )

      state = api.luaL_newstate

      expect(state.class).to eq(FFI::Pointer)
      expect(api.luaL_openlibs(state)).to eq(nil)
      expect(api.luaL_loadstring(state, 'return math.pow(2, 3);')).to eq(0)
      expect(api.lua_pcall(state, 0, 1, 0)).to eq(0)
      expect(api.lua_tonumber(state, -1)).to eq(8.0)
      expect(api.lua_pop(state)).to eq(nil)
      expect(api.lua_close(state)).to eq(nil)
    end
  end
end
