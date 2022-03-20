require 'yaml'

require './controllers/api'
require './controllers/interpreter'

RSpec.describe do
  context '5.4.4' do
    it do
      config = YAML.load_file('config/tests.yml')['5.4.4']

      component = Controller::API[:handle!].(shared_objects: [config['shared_object']])

      expect(component.keys).to eq(%i[api signatures meta])

      expect(component[:meta]).to eq(
        {
          options: { shared_objects: [config['shared_object']] },
          elected: {
            api_reference: '5.4.2',
            shared_objects: [config['shared_object']]
          }
        }
      )

      expect(component[:signatures].size).to be > 100

      expect(component[:api].respond_to?(:luaL_newstate)).to eq(true)
      expect(component[:api].respond_to?(:lua_pop)).to eq(true)
      expect(component[:api].respond_to?(:luaH_new)).to eq(false)

      expect(component[:signatures][:luaL_newstate].keys).to eq(
        %i[source input output]
      )

      expect(component[:signatures][:lua_pop].keys).to eq(
        %i[source macro requires]
      )

      expect(component[:signatures][:lua_tocfunction][:output]).to eq(:cfunction)
      expect(component[:signatures][:luaH_new]).to eq(nil)
    end
  end

  context '3.2.2' do
    it do
      config = YAML.load_file('config/tests.yml')['3.2.2']

      component = Controller::API[:handle!].(shared_objects: [config['shared_object']])

      expect(component.keys).to eq(%i[api signatures meta])

      expect(component[:meta]).to eq(
        {
          options: { shared_objects: [config['shared_object']] },
          elected: {
            api_reference: '3.2.2',
            shared_objects: [config['shared_object']]
          }
        }
      )

      expect(component[:signatures].size).to be > 100

      expect(component[:api].respond_to?(:luaH_new)).to eq(true)
      expect(component[:api].respond_to?(:luaL_newstate)).to eq(false)

      expect(component[:signatures][:luaH_new].keys).to eq(
        %i[source input output]
      )

      expect(component[:signatures][:luaL_newstate]).to eq(nil)
    end
  end

  context 'exact versions' do
    it do
      config = YAML.load_file('config/tests.yml')

      ['5.4.2', '5.0.3', '3.2.2'].each do |version|
        shared_objects = config[version]['shared_objects']

        shared_objects ||= [config[version]['shared_object']]

        component = Controller::API[:handle!].(
          shared_objects: shared_objects
        )

        expect(component.keys).to eq(%i[api signatures meta])

        expect(component[:signatures].size).to be > 50

        expect(component[:meta][:elected]).to eq(
          {
            api_reference: version,
            shared_objects: shared_objects
          }
        )
      end

      config = YAML.load_file('config/tests.yml')['5.4.4']

      options = { shared_objects: [config['shared_object']] }

      Controller::Interpreter[:handle!].(Controller::API[:handle!].(options), options)
    end
  end

  context 'Dangerous combinations: 4.0.1 + 5.4.4' do
    it 'segmentation fault', skip: true do
      config = YAML.load_file('config/tests.yml')

      Controller::API[:handle!].(
        shared_objects: config['4.0.1']['shared_objects']
      )[:api]

      api5 = Controller::API[:handle!].(
        shared_objects: [config['5.4.4']['shared_object']]
      )[:api]

      # TODO: Find a way to fix that.
      state = api5.luaL_newstate
      api5.luaL_openlibs(state)
    end
  end
end
