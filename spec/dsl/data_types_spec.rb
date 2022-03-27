require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  context 'fennel' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(
        shared_object: config['5.4.2']['shared_object'],
        package_path: config['5.4.2']['fennel']
      )

      config['luarocks']['path'].each { |path| state.add_package_path(path) }

      expect(state.eval('return 1 + 1')).to eq(2)

      fennel = state.eval('return require("fennel")')

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(fennel.keys).to include(*%w[dofile eval repl version view])

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(fennel.values.map(&:class).map(&:to_s)).to include(
        *%w[Array Hash Proc String String String]
      )

      expect(state.eval('return 1 + 1')).to eq(2)
    end
  end

  context 'supernova' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.4.2']['shared_object'])

      config['luarocks']['path'].each { |path| state.add_package_path(path) }

      expect(state.eval('return 1 + 1')).to eq(2)

      supernova = state.eval('return require("supernova")')

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(supernova.keys).to include(*%w[enable set-colors set-theme])

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(supernova.values.map(&:class).map(&:to_s)).to include(
        *%w[Hash Proc String TrueClass]
      )

      expect(state.eval('return 1 + 1')).to eq(2)
    end
  end

  context 'dkjson' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.4.2']['shared_object'])

      config['luarocks']['path'].each { |path| state.add_package_path(path) }

      expect(state.eval('return 1 + 1')).to eq(2)

      dkjson = state.eval('return require("dkjson")')

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(dkjson.keys).to include(*%w[decode encode])

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(dkjson.values.map(&:class).map(&:to_s)).to include(*%w[Hash Proc String])

      expect(state.eval('return 1 + 1')).to eq(2)
    end
  end
end
