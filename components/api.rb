require 'ffi'

module Component
  API = {
    open!: ->(shared_objects) {
      api = Module.new

      api.extend FFI::Library

      # TODO: Lua Constants
      # attach_variable

      if shared_objects.size > 1
        # TODO: Dangerous
        api.ffi_lib_flags(:global, :now)
      else
        api.ffi_lib_flags(:local, :now)
      end

      api.ffi_lib(*shared_objects.map { |o| o[:path] })

      api
    },

    inject_callbacks!: ->(api, reference, injections) {
      injections[:callbacks].each do |callback|
        api.callback(*callback[:ffi])
        reference[:signatures][:functions].each do |signature|
          next unless callback[:overwrite][signature[:ffi].first]

          signature[:ffi] = [
            signature[:ffi].first, *callback[:overwrite][signature[:ffi].first]
          ]
        end
      end
    },

    attach!: ->(api, reference, injections) {
      API[:inject_callbacks!].(api, reference, injections)

      signatures = {}

      reference[:signatures][:functions].each do |signature|
        exists = false

        api.ffi_libraries.each do |ffi_library|
          exists = true if ffi_library.find_function(signature[:ffi].first.to_s)
        end

        next unless exists

        api.attach_function(*signature[:ffi])
        signatures[signature[:ffi].first] = {
          source: signature[:source],
          input: signature[:ffi][1], output: signature[:ffi][2]
        }
      end

      API[:inject_macros!].(api, signatures, reference, injections)
    },

    inject_macros!: ->(api, signatures, reference, injections) {
      reference[:signatures][:macros].each do |macro_signature|
        macro = injections[:macros][macro_signature[:name].to_sym]
        next unless macro

        missing = macro[:requires].detect { |function| !signatures[function] }

        next if missing

        api.define_singleton_method macro_signature[:name], macro[:injection]
        api.define_method macro_signature[:name], macro[:injection]

        signatures[macro_signature[:name].to_sym] = {
          source: macro_signature[:source], macro: true,
          requires: macro[:requires].map { |f| signatures[f] }
        }
      end

      { api: api, signatures: signatures }
    }
  }
end
