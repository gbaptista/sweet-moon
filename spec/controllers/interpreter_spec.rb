require 'yaml'

require './controllers/api'
require './controllers/interpreter'

RSpec.describe do
  context '5.4.4' do
    it do
      config = YAML.load_file('config/tests.yml')['5.4.4']

      options = { shared_objects: [config['shared_object']] }

      api = Controller::API[:handle!].(options)
      interpreter = Controller::Interpreter[:handle!].(api, options)

      expect(interpreter.keys).to eq(%i[interpreter meta])

      expect(api[:meta]).to eq(
        options: { shared_objects: [config['shared_object']] },
        elected: { api_reference: '5.4.2', shared_objects: [config['shared_object']] }
      )

      expect(interpreter[:meta]).to eq(
        options: { shared_objects: [config['shared_object']] },
        elected: { interpreter: '5.4' },
        runtime: { lua: 'Lua 5.4' }
      )
    end
  end
end
