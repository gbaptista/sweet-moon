require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  context 'readline' do
    context 'isolated state', :skip do
      it do
        SweetMoon.global.clear

        config = YAML.load_file('config/tests.yml')

        SweetMoon.global.config(shared_object: config['5.4.2']['shared_object'])

        expect(SweetMoon.global.api.meta.to_h).to eq(
          api_reference: '5.4.2',
          shared_objects: [config['5.4.2']['shared_object']],
          global_ffi: false
        )

        state = SweetMoon::State.new(
          shared_object: config['5.4.2']['shared_object'],
          global_ffi: true
        )

        config['luarocks']['path'].each { |path| state.add_package_path(path) }
        config['luarocks']['cpath'].each { |path| state.add_package_cpath(path) }

        expect(state.meta.to_h).to eq(
          api_reference: '5.4.2',
          global_ffi: true,
          interpreter: '5.4',
          runtime: 'Lua 5.4',
          shared_objects: [config['5.4.2']['shared_object']]
        )

        expect(SweetMoon.global.api.meta.to_h).to eq(
          api_reference: '5.4.2',
          shared_objects: [config['5.4.2']['shared_object']],
          global_ffi: false
        )

        expect(state.eval('return require("readline")').keys).to include(
          *%w[set_readline_name set_options readline
              set_completion_append_character set_complete_function]
        )
      end
    end

    context 'isolated state error' do
      it do
        SweetMoon.global.clear

        config = YAML.load_file('config/tests.yml')

        SweetMoon.global.config(
          shared_object: config['5.4.2']['shared_object']
        )

        expect(SweetMoon.global.api.meta.to_h).to eq(
          api_reference: '5.4.2',
          shared_objects: [config['5.4.2']['shared_object']],
          global_ffi: false
        )

        expect(SweetMoon.global.state.meta.to_h).to eq(
          api_reference: '5.4.2',
          global_ffi: false,
          interpreter: '5.4',
          runtime: 'Lua 5.4',
          shared_objects: [config['5.4.2']['shared_object']]
        )

        state = SweetMoon::State.new(
          shared_object: config['5.4.2']['shared_object']
        )

        config['luarocks']['path'].each { |path| state.add_package_path(path) }
        config['luarocks']['cpath'].each { |path| state.add_package_cpath(path) }

        expect(state.meta.to_h).to eq(
          api_reference: '5.4.2',
          global_ffi: false,
          interpreter: '5.4',
          runtime: 'Lua 5.4',
          shared_objects: [config['5.4.2']['shared_object']]
        )

        expect(SweetMoon.global.api.meta.to_h).to eq(
          api_reference: '5.4.2',
          shared_objects: [config['5.4.2']['shared_object']],
          global_ffi: false
        )

        expect { state.eval('return require("readline")') }.to raise_error(
          an_instance_of(SweetMoon::Errors::LuaRuntimeError),
          /error loading module 'C-readline'/
        )
      end
    end
  end
end
