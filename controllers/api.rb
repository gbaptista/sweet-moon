require_relative '../components/injections'
require_relative '../components/api'
require_relative '../components/io'
require_relative '../dsl/errors'

require_relative '../logic/api'
require_relative '../logic/shared_object'

module Controller
  API = {
    handle!: ->(options) {
      shared_objects = API[:elect_shared_objects!].(options[:shared_objects])

      api = Component::API[:open!].(shared_objects)

      api_reference = API[:elect_api_reference!].(
        api.ffi_libraries, options[:api_reference]
      )

      injections = Component::Injections[api_reference[:version]]
      injections = if injections
                     injections[:injections]
                   else
                     { macros: {},
                       callbacks: [] }
                   end

      component = Component::API[:attach!].(api, api_reference, injections)

      component[:meta] = {
        options: options,
        elected: {
          shared_objects: shared_objects.map { |o| o[:path] },
          api_reference: api_reference[:version]
        }
      }

      component
    },

    elect_shared_objects!: ->(paths) {
      candidates = []
      shared_objects = []

      if paths&.size&.positive?
        candidates = paths

        shared_objects = Component::IO[:reject_non_existent!].(paths).map do |path|
          { path: path }
        end
      else
        bases = %w[/usr/lib /usr/lib/* /usr/local/lib /opt/local/lib]

        # XDG
        if ENV['HOME']
          bases << "#{ENV['HOME']}/.local/lib"
          bases << "#{ENV['HOME']}/.local/lib/*"
        end

        bases.each do |base|
          candidates.concat Component::IO[:find_by_pattern!].("#{base}/liblua*so*")
          candidates.concat Component::IO[:find_by_pattern!].("#{base}/liblua*dylib*")
        end

        candidates = Component::IO[:reject_non_existent!].(candidates)

        shared_objects = Logic::SharedObject[:choose].(candidates)
      end

      if shared_objects.size.zero?
        raise SweetMoon::Errors::SweetMoonError,
              "Lua shared object (liblua.so) not found: #{candidates}"
      end

      shared_objects
    },

    elect_api_reference!: ->(ffi_libraries, api_reference) {
      availabe_candidates = Logic::API[:candidates].values

      if api_reference
        availabe_candidates = availabe_candidates.select do |candidate|
          candidate[:version] == api_reference
        end

        if availabe_candidates.size.zero?
          raise SweetMoon::Errors::SweetMoonError,
                "API Reference #{api_reference} not available."
        end
      end

      candidates = API[:calculate_compatibility!].(
        availabe_candidates, ffi_libraries
      )

      candidates.sort_by do |_, functions|
        functions[:found]
      end.reverse

      # TODO: This is the best strategy?
      # version = candidates.sort_by do |_, functions|
      #   functions[:proportion]
      # end.reverse.first.first

      version = candidates.sort_by do |_, functions|
        functions[:found] * functions[:proportion]
      end.reverse.first.first

      Logic::API[:candidates][version]
    },

    calculate_compatibility!: ->(availabe_candidates, ffi_libraries) {
      candidates = {}

      availabe_candidates.each do |candidate|
        candidates[candidate[:version]] = {
          found: 0,
          expected: (
            candidate[:signatures][:functions].size +
            candidate[:signatures][:macros].size
          )
        }
        candidate[:signatures][:functions].each do |signature|
          function = signature[:ffi].first

          ffi_libraries.each do |ffi_library|
            if ffi_library.find_function(function.to_s)
              candidates[candidate[:version]][:found] += 1
              break
            end
          end
        end

        candidates[candidate[:version]][:proportion] = (
          candidates[candidate[:version]][:found].to_f /
          candidates[candidate[:version]][:expected]
        )
      end

      candidates
    }
  }
end
