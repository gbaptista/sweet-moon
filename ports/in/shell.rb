require_relative '../../controllers/cli/version'
require_relative '../../controllers/cli/help'
require_relative '../../controllers/cli/signatures'
require_relative '../../controllers/cli/cli'

module Port
  module In
    Shell = {
      handle!: -> {
        case ARGV.first
        when 'version' then Controller::CLI::Version[:handle!].()
        when 'signatures' then Controller::CLI::Signatures[:handle!].(ARGV[1],
                                                                      ARGV[2])
        when 'lua' then Controller::CLI::CLI[:handle!].(ARGV[1..-1])
        when 'fennel' then Controller::CLI::CLI[:handle!].(ARGV[1..-1], true)
        else; Controller::CLI::Help[:handle!].()
        end
      }
    }
  end
end
