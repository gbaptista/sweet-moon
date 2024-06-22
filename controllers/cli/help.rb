require_relative '../../ports/out/shell'
require_relative '../../logic/spec'

module Controller
  module CLI
    Help = {
      handle!: -> {
        Port::Out::Shell[:dispatch!].(
          "\n#{Logic::Spec[:command]} #{Logic::Spec[:version]}\n\n" \
          "usage:\n  " \
          "#{Logic::Spec[:command]} version\n  " \
          "#{Logic::Spec[:command]} signatures /lua/source [output.rb]\n  " \
          "#{Logic::Spec[:command]} lua -i\n  " \
          "#{Logic::Spec[:command]} lua file.lua [-o]\n  " \
          "#{Logic::Spec[:command]} lua -e \"print(1 + 2);\" [-o]\n  " \
          "#{Logic::Spec[:command]} fennel -i\n  " \
          "#{Logic::Spec[:command]} fennel file.fnl [-o]\n  " \
          "#{Logic::Spec[:command]} fennel -e \"(+ 1 2)\" [-o]" \
          "\n\n"
        )
      }
    }
  end
end
