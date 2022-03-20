require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  context 'SweetMoon' do
    it do
      config = YAML.load_file('config/tests.yml')

      file = "#{Time.now.to_i}-xpto.so"

      expect { SweetMoon.global.config(shared_object: file) }.to raise_error(
        an_instance_of(SweetMoon::Errors::SweetMoonError),
        "Lua shared object (liblua.so) not found: [\"#{file}\"]"
      )

      expect do
        SweetMoon.global.config(
          shared_object: config['5.4.2']['shared_object'],
          api_reference: 2.8
        )
      end.to raise_error(
        an_instance_of(SweetMoon::Errors::SweetMoonError), 'API Reference 2.8 not available.'
      )

      expect do
        SweetMoon.global.config(
          shared_object: config['5.4.2']['shared_object'],
          interpreter: 0.1
        )
      end.to raise_error(
        an_instance_of(SweetMoon::Errors::SweetMoonError), 'Interpreter 0.1 not available.'
      )

      expect do
        expect(SweetMoon.global.state.destroy).to eq(nil)
      end.to raise_error(NoMethodError)
    end
  end

  context 'Lua Errors' do
    it do
      config = YAML.load_file('config/tests.yml')

      SweetMoon.global.clear

      SweetMoon.global.config(shared_object: config['5.4.2']['shared_object'])

      expect(SweetMoon.global.state.eval('return 1 + 1')).to eq(2)

      file = "#{Time.now.to_i}-xpto.lua"

      expect do
        SweetMoon.global.state.load(file)
      end.to raise_error(
        an_instance_of(SweetMoon::Errors::LuaFileError),
        "cannot open #{file}: No such file or directory"
      )

      expect(SweetMoon.global.state.eval('return 1 + 1')).to eq(2)

      expect do
        SweetMoon.global.state.eval('a')
      end.to raise_error(
        an_instance_of(SweetMoon::Errors::LuaSyntaxError),
        '[string "a"]:1: syntax error near <eof>'
      )

      expect(SweetMoon.global.state.eval('return 1 + 1')).to eq(2)

      expect do
        SweetMoon.global.state.eval('return 1 + true')
      end.to raise_error(
        an_instance_of(SweetMoon::Errors::LuaRuntimeError),
        '[string "return 1 + true"]:1: attempt to perform' \
        ' arithmetic on a boolean value'
      )

      expect(SweetMoon.global.state.eval('return 1 + 1')).to eq(2)

      expect do
        SweetMoon::State.new(shared_object: config['3.2.2']['shared_object'])
      end.to raise_error(
        an_instance_of(SweetMoon::Errors::SweetMoonError),
        /No compatible interpreter found for Lua C API 3\.2\.2/
      )

      expect do
        SweetMoon::State.new(shared_object: config['?']['shared_object'])
      end.to raise_error(
        an_instance_of(SweetMoon::Errors::SweetMoonError),
        /No compatible interpreter found for Lua C API 3\.2\.2/
      )

      state = SweetMoon::State.new(shared_object: config['5.0.3']['shared_object'])

      expect do
        state.add_package_path('/?.lua')
      end.to raise_error(
        an_instance_of(SweetMoon::Errors::SweetMoonError),
        'package.path requires Lua >= 5.1 or LuaJIT >= 2; Current: Lua 5.0.3 (5.0)'
      )

      state = SweetMoon::State.new(shared_object: config['5.0.3']['shared_object'])

      expect do
        state.fennel
      end.to raise_error(
        an_instance_of(SweetMoon::Errors::SweetMoonError),
        'Fennel requires Lua >= 5.1 or LuaJIT >= 2; Current: Lua 5.0.3 (5.0)'
      )
    end
  end

  context 'Avoid Toxic Combinations for Global' do
    it do
      config = YAML.load_file('config/tests.yml')

      expect(
        SweetMoon::API.new(
          shared_object: config['?']['shared_object']
        ).meta.api_reference
      ).to eq('3.2.2')

      expect(
        SweetMoon::API.new(
          shared_object: config['5.0.3']['shared_object']
        ).meta.api_reference
      ).to eq('5.0.3')
    end
  end
end
