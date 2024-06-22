require_relative 'io'

module Logic
  SharedObject = {
    choose: ->(candidate_paths, options = {}) {
      candidates = candidate_paths.map do |path|
        SharedObject[:normalize].(path)
      end

      unless options[:jit].nil?
        candidates = candidates.select do |candidate|
          options[:jit] ? candidate[:inferences][:jit] : !candidate[:inferences][:jit]
        end
      end

      if options[:version]
        candidates = candidates.select do |candidate|
          if candidate[:inferences][:version]
            !candidate[:inferences][:version][/#{options[:version]}/].nil?
          else
            false
          end
        end
      end

      elected = candidates.filter do |candidate|
        candidate[:path] !~ /\+\+/ # Exclude C++ Shared Objects
      end.max_by do |candidate|
        Gem::Version.new(candidate[:inferences][:version] || '0')
      end

      return [] if elected.nil?

      [elected]
    },

    normalize: ->(path) {
      inferred_versions = IO[:file_name].(
        path
      ).scan(/(\d+(\.\d+)*)/).map(&:first)

      inferred_versions = inferred_versions.map do |inferred_version|
        inferred_version.split('.').map { |part| part.chars.join('.') }.join('.')
      end

      inferred_version = inferred_versions.max_by do |raw_inferred_version|
        Gem::Version.new(raw_inferred_version || '0')
      end

      { path:,
        inferences: { jit: !path[/jit/].nil?, version: inferred_version } }
    }
  }
end
