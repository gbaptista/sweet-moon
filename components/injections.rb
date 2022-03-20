require_relative 'injections/injections_503'
require_relative 'injections/injections_514'
require_relative 'injections/injections_542'

module Component
  Injections = {
    '5.0.3' => { version: '5.0.3', injections: V503::Injections },
    '5.1.4' => { version: '5.1.4', injections: V514::Injections },
    '5.4.2' => { version: '5.4.2', injections: V542::Injections }
  }
end
