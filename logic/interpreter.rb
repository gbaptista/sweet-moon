require_relative 'interpreters/interpreter_50'
require_relative 'interpreters/interpreter_51'
require_relative 'interpreters/interpreter_54'

module Logic
  Interpreter = {
    candidates: {
      '5.0' => { version: '5.0', requires: V50::Interpreter[:requires] },
      '5.1' => { version: '5.1', requires: V51::Interpreter[:requires] },
      '5.4' => { version: '5.4', requires: V54::Interpreter[:requires] }
    },

    elect: ->(signatures, api_version, options = {}) {
      interpreters = Interpreter[:candidates].values

      if options[:interpreter]
        interpreters = interpreters.select do |interpreter|
          interpreter[:version].to_s == options[:interpreter]
        end

        if interpreters.size.zero?
          return {
            compatible: false,
            error: "Interpreter #{options[:interpreter]} not available."
          }
        end
      end

      results = {}

      interpreters.each do |interpreter|
        results[interpreter[:version]] = Interpreter[:check_compatibility].(
          interpreter, signatures
        )
      end

      result = Interpreter[:choose_compatible].(results)

      return result if result

      { compatible: false,
        error: Interpreter[:closest_error_message].(api_version, results) }
    },

    closest_error_message: ->(api_version, candidates) {
      closest = candidates.values.sort_by do |candidate|
        Gem::Version.new(candidate[:version].gsub(/.+:/, '') || '0')
      end.reverse

      closest = closest.min_by { |candidate| candidate[:missing].size }

      message = "Missing in the closest version (#{closest[:version]}):"

      closest[:missing].sort.each_slice(4).each do |functions|
        message += "\n  #{functions.join(' ')}"
      end

      "No compatible interpreter found for Lua C API #{api_version}.\n#{message}"
    },

    choose_compatible: ->(candidates) {
      candidates = candidates.values.select do |candidate|
        candidate[:compatible]
      end

      candidates.max_by do |candidate|
        Gem::Version.new(candidate[:version].gsub(/.+:/, '') || '0')
      end
    },

    check_compatibility: ->(interpreter, signatures) {
      result = { version: interpreter[:version], compatible: true, missing: [] }

      interpreter[:requires].each do |required|
        unless signatures[required]
          result[:compatible] = false
          result[:missing] << required
        end
      end

      result
    }
  }
end
