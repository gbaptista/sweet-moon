require_relative '../../ports/out/shell'
require_relative '../../logic/spec'

module Controller
  module CLI
    Version = {
      handle!: -> {
        Port::Out::Shell[:dispatch!].(
          "\n#{Logic::Spec[:command]} #{Logic::Spec[:version]}\n\n"
        )
      }
    }
  end
end
