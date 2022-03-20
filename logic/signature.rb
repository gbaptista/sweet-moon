require_relative 'signatures/ffi_types'

module Logic
  Signature = {
    lua_to_ffi_types: Signatures::FFITypes,

    to_ffi: ->(signature) {
      result = [
        signature[:name].to_sym,
        signature[:input].map do |input|
          input_type = Signature[:lua_to_ffi_types][input[:primitive].to_sym]

          if input[:pointer]
            :pointer
          elsif input_type
            input_type.to_sym
          else
            raise "missing primitive: #{input[:primitive]}"
          end
        end
      ]

      output_type = Signature[:lua_to_ffi_types][
        signature[:output][:primitive].to_sym
      ]

      result << if signature[:output][:pointer]
                  :pointer
                elsif output_type
                  output_type.to_sym
                else
                  raise "missing primitive: #{signature[:output][:primitive]}"
                end

      result[1].pop while result[1].last == :void

      result
    },

    extract_from_nm: ->(output) {
      output.lines.map do |line|
        line.sub(/\S+\s\S+\s/, '').strip
      end.uniq.sort
    },

    remove_comments: ->(source) {
      source.gsub(%r{/\*([\s\S]*?)\*/}, '')
    },

    extract_type_from_source: ->(source) {
      sanitized_source = Signature[:sanitize_source_name].(source)

      parts = sanitized_source
              .gsub(/[{()].*/, '').gsub('*', '').gsub(/\s+/, ' ')
              .strip.split(/\s/)

      return nil if parts.size < 3

      base_index = 1

      if %w[unsigned signed const].include? parts[base_index].gsub(';', '')
        base_index += 1
        return nil if parts.size < 4
      end

      primitive = parts[base_index].gsub(';', '')
      type = parts[base_index + 1].gsub(';', '')

      { type: type, primitive: primitive }
    },

    extract_types_from_header: ->(source, types = {}) {
      source = Signature[:remove_comments].(source)

      # remove { ... }
      source = source.gsub(/\{([\s\S]*?)\}/, '')

      source.each_line do |line|
        if line[/typedef/]
          type = Signature[:extract_type_from_source].(line)
          types[type[:type]] = type[:primitive] if type
        end
      end

      types
    },

    extract_from_header: ->(source) {
      source = Signature[:remove_comments].(source)

      signatures = []

      current_index = 0

      source.each_line.with_index do |line, line_index|
        next unless line_index > current_index - 1

        line = line.strip

        if line[/\w\)*\s*\(/] && !line[/typedef|^if\s/]
          signature = line

          current_index = line_index + 1

          buffer = 100

          while signature.scan(/\(/).size != signature.scan(/\)/).size &&
                buffer.positive?

            signature = "#{signature} #{source.lines[current_index]}"
            current_index += 1

            buffer -= 1
          end

          signature = signature.gsub(/\n/, ' ').gsub(/\s+/, ' ').strip

          signatures << signature
        end
      end

      signatures.uniq.sort
    },

    sanitize_source_name: ->(source) {
      # int (*lorem) (lua_State *L, const void* p);
      sanitized_source = source

      candidate = sanitized_source[/\(\s*\**\s*\w+\s*\)\s*\(/]

      if candidate
        sanitized_source = sanitized_source.sub(
          candidate, "#{candidate.gsub('(', '').gsub(')', '')}("
        )
      end

      sanitized_source
    },

    is_macro?: ->(sanitized_source) {
      function_source = sanitized_source.strip

      if function_source[/^#define/] && function_source[/\)\s*\w*\(/]
        function_source = function_source.gsub(/^#define\s*/, '')
        function_source = function_source.sub(/\)\s*\w*\(.*/, ')')
        return function_source
      end

      false
    },

    extract_macro_from_source: ->(function_source, sanitized_source) {
      input = /\(([^()]+)\)/.match(sanitized_source)

      input = if input
                input[1].split(',').map(&:strip).map do |parameter|
                  Signature[:parse_parameter].(parameter, {})
                end
              else
                []
              end

      function = {
        name: sanitized_source.gsub(/\(.*/, '').strip,
        macro: true,
        input: input.map { |parameter| { name: parameter[:type] } },
        source: function_source
      }

      function
    },

    extract_from_source: ->(function_source, types = {}) {
      sanitized_source = Signature[:sanitize_source_name].(function_source)

      macro = Signature[:is_macro?].(sanitized_source)

      return Signature[:extract_macro_from_source].(function_source, macro) if macro

      begin
        input = /\(([^()]+)\)/
                .match(sanitized_source)[1].split(',').map(&:strip)
                .map do |parameter|
          Signature[:parse_parameter].(parameter,
                                       types)
        end
      rescue StandardError
        return nil
      end

      function = Signature[:parse_function].(
        sanitized_source.sub(/\(([^()]+)\)/, '').sub(';', '').strip, types
      )

      return nil if function.nil?

      input.last[:name] = nil if input.last[:name] == '...'

      if input.last[:type] == '...' || input.last[:name] == '...'
        input.last[:type] = 'va_list'
        input.last[:primitive] = 'va_list'
      end

      function[:input] = input
      function[:source] = function_source

      function
    },

    parse_parameter: ->(raw_parameter, types = {}) {
      parts = raw_parameter.split(/\s+/)

      parameter = { pointer: false, name: nil, type: nil, constant: false }

      parts.each do |part|
        parameter[:constant] = true if part.gsub('*', '').strip == 'const'

        parameter[:pointer] = true if part[/\*/]
      end

      parts = parts.reject do |part|
        part.gsub('*', '').strip == 'const'
      end

      parameter[:name] = parts.pop if parts.size > 1

      parameter[:type] = parts.pop

      parameter[:name] = parameter[:name].sub(/\*/, '') if parameter[:name]
      parameter[:type] = parameter[:type].sub(/\*/, '') if parameter[:type]

      parameter[:primitive] = parameter[:type]

      budget = 10_000

      if parameter[:primitive]
        while types[parameter[:primitive]] && budget.positive?
          parameter[:primitive] = types[parameter[:primitive]]
          budget -= 1
        end
      end

      warn "Fail to find primitive: #{parameter[:primitive]}" if budget.zero?

      parameter
    },

    parse_function: ->(raw_function, types) {
      output = Signature[:parse_parameter].(raw_function, types)

      function_name = output.delete(:name)

      return nil if function_name.nil? || output[:type].nil?

      { name: function_name, output: output }
    }
  }
end
