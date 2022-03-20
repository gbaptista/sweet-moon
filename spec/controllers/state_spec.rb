require 'yaml'

require './controllers/api'
require './controllers/interpreter'
require './controllers/state'

RSpec.describe do
  context '5.4.4' do
    it do
      config = YAML.load_file('config/tests.yml')['5.4.4']

      options = { shared_objects: [config['shared_object']] }

      api_module = Controller::API[:handle!].(options)
      interpreter_module = Controller::Interpreter[:handle!].(api_module, options)

      api = api_module[:api]
      interpreter = interpreter_module[:interpreter]

      state = Controller::State[:create!].(api, interpreter)[:state]

      expect(
        Controller::State[:eval!].(
          api, interpreter, state, 'return 1 + 1.5;'
        )[:output]
      ).to eq(2.5)

      expect(
        Controller::State[:eval!].(
          api, interpreter, state, 'return { a = "1", b = 2 };'
        )[:output]
      ).to eq({ 'a' => '1', 'b' => 2 })

      expect(
        Controller::State[:destroy!].(api, interpreter, state)
      ).to eq(state: nil)
    end
  end
end
