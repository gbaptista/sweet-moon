require 'yaml'

require_relative '../../ports/out/shell'

module Controller
  module CLI
    CLI = {
      handle!: ->(arguments, _fennel = false) {
        options = {}

        arguments = arguments.select do |argument|
          if argument[/^-/]
            options[argument] = true
            false
          else
            true
          end
        end

        if options['-i']
          return Port::Out::Shell[:dispatch!].(YAML.dump({ TODO: true }))
        end

        input = arguments.first

        output = options['-e'] ? "TODO eval #{input}" : "TODO file #{input}"

        Port::Out::Shell[:dispatch!].(output) if options['-o']
      }
    }
  end
end
