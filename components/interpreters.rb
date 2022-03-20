require_relative 'interpreters/50/interpreter'
require_relative 'interpreters/51/interpreter'
require_relative 'interpreters/54/interpreter'

module Component
  Interpreters = {
    '5.0' => { version: '5.0', interpreter: V50::Interpreter },
    '5.1' => { version: '5.1', interpreter: V51::Interpreter },
    '5.4' => { version: '5.4', interpreter: V54::Interpreter }
  }
end
