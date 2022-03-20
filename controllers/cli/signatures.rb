require 'pp'
require 'yaml'

require_relative '../../components/io'
require_relative '../../logic/io'
require_relative '../../logic/signature'
require_relative '../../ports/out/shell'

module Controller
  module CLI
    Signatures = {
      handle!: ->(source_path, output_path = nil) {
        functions = Signatures[:functions_from_shared_objects!].(source_path)
        signatures, types = Signatures[:signatures_from_headers!].(source_path)

        result = Signatures[:match_functions_and_signatures!].(
          functions, signatures, types
        )

        primitives = Signatures[:collect_primitives!].(result[:attachables])

        Signatures[:print_samples!].(result, functions, signatures, primitives)

        return if output_path.nil?

        output = {
          functions: result[:attachables].values.map do |a|
                       { source: a[:source], ffi: a[:ffi] }
                     end,
          macros: result[:macros].values.map do |a|
                    { source: a[:source], name: a[:name],
                      input: a[:input].map { |i| i[:name] } }
                  end
        }

        output[:functions] = output[:functions].sort_by { |a| a[:source] }
        output[:macros] = output[:macros].sort_by { |a| a[:source] }

        Component::IO[:write!].(output_path, output.pretty_inspect)

        Port::Out::Shell[:dispatch!].(
          "\n > attachables dumped to: \"#{output_path}\""
        )
      },

      print_samples!: ->(result, functions, signatures, primitives) {
        Port::Out::Shell[:dispatch!].("#{functions.size} functions:\n")
        2.times { Port::Out::Shell[:dispatch!].(" #{functions.sample}") }

        Port::Out::Shell[:dispatch!].("\n#{signatures.size} signatures:\n")
        2.times { Port::Out::Shell[:dispatch!].(" #{signatures.sample}") }

        Port::Out::Shell[:dispatch!].("\n#{result[:attachables].size} attachables:\n")
        2.times do
          Port::Out::Shell[:dispatch!].(
            " #{result[:attachables].values.sample[:name]}"
          )
        end

        Port::Out::Shell[:dispatch!].("\n#{result[:macros].size} macros:\n")
        2.times do
          Port::Out::Shell[:dispatch!].(" #{result[:macros].values.sample[:name]}")
        end

        Port::Out::Shell[:dispatch!].("\n#{result[:missing].size} missing:\n")
        (result[:missing].size < 3 ? 1 : 3).times do
          Port::Out::Shell[:dispatch!].(" #{result[:missing].sample}")
        end

        Port::Out::Shell[:dispatch!].("\n#{primitives.size} primitives:\n")
        Port::Out::Shell[:dispatch!].(
          YAML.dump(primitives).lines[1..-1].map { |line| "  #{line}" }
        )
      },

      collect_primitives!: ->(attachables) {
        types = {}

        attachables.each_value do |attachable|
          unless attachable[:output][:pointer]
            if types[attachable[:output][:primitive]].nil?
              types[attachable[:output][:primitive]] = 0
            end
            types[attachable[:output][:primitive]] += 1
          end

          attachable[:input].each do |input|
            unless input[:pointer]
              types[input[:primitive]] = 0 if types[input[:primitive]].nil?
              types[input[:primitive]] += 1
            end
          end
        end

        types
      },

      match_functions_and_signatures!: ->(functions, signatures, types) {
        exists = {}

        functions.each { |function| exists[function] = true }

        attachables = {}
        macros = {}
        missing = []

        signatures = signatures.map do |signature|
          Logic::Signature[:extract_from_source].(signature, types)
        end.compact

        signatures.each do |signature|
          next unless signature[:name][/^lua/i] # TODO: Is it true for Lua < 5?

          if signature[:macro]
            macros[signature[:name].to_sym] = signature
          elsif exists[signature[:name]]
            attachables[signature[:name].to_sym] = signature
          end
        end

        attachables.values.map do |attachable|
          attachable[:ffi] = Logic::Signature[:to_ffi].(attachable)
        end

        functions.each do |function|
          missing << function unless attachables[function.to_sym]
        end

        { attachables: attachables, macros: macros, missing: missing }
      },

      functions_from_shared_objects!: ->(path) {
        shared_objects = Component::IO[:find_recursively!].(
          path
        ).select do |candidate|
          Logic::IO[:extension].(candidate) == '.so'
        end

        puts shared_objects

        functions = []

        command = 'nm --demangle --dynamic --defined-only --extern-only'

        shared_objects.each do |shared_object_path|
          functions.concat(
            Logic::Signature[:extract_from_nm].(`#{command} #{shared_object_path}`)
          )
        end

        functions.uniq.sort
      },

      signatures_from_headers!: ->(path) {
        headers = Component::IO[:find_recursively!].(path).select do |candidate|
          Logic::IO[:extension].(candidate) == '.h'
        end

        sources = headers.map { |header_path| Component::IO[:read!].(header_path) }

        types = {}

        sources.each do |source|
          types = Logic::Signature[:extract_types_from_header].(source, types)
        end

        signatures = []

        sources.each do |source|
          signatures.concat(
            Logic::Signature[:extract_from_header].(source)
          )
        end

        [signatures.uniq.sort, types]
      }
    }
  end
end
