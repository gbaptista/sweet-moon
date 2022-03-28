require_relative 'errors'
require_relative 'concerns/packages'
require_relative 'concerns/fennel'
require_relative '../components/default'

module DSL
  class State
    include DSL::Concerns::Packages
    include DSL::Concerns::Fennel

    attr_reader :meta, :api

    def initialize(api_component, interpreter_component, controller, options = {})
      @api = api_component[:api]
      @interpreter = interpreter_component[:interpreter]
      @controller = controller

      @state = @controller[:create!].(@api, @interpreter)[:state]

      build_meta(api_component, interpreter_component)

      add_package_path(options[:package_path]) if options[:package_path]
      add_package_cpath(options[:package_cpath]) if options[:package_cpath]
    end

    def raw
      @state
    end

    def eval(input, outputs = 1)
      options = _build_options(outputs, nil)

      @controller[:eval!].(
        @api, @interpreter, state, input, options[:outputs]
      )[:output]
    end

    def load(path, outputs = 1)
      options = _build_options(outputs, nil)

      @controller[:load!].(
        @api, @interpreter, state, path, options[:outputs]
      )[:output]
    end

    def get(variable, key = nil)
      @controller[:get!].(@api, @interpreter, state, variable, key)[:output]
    end

    def set(variable, key_or_value, value = nil)
      @controller[:set!].(
        @api, @interpreter, state, variable, key_or_value, value
      )[:output]
    end

    def destroy
      @controller[:destroy!].(@api, @interpreter, state) if @state
      @state = nil
    end

    def clear
      @controller[:destroy!].(@api, @interpreter, state) if @state
      @state = @controller[:create!].(@api, @interpreter)[:state]
      nil
    end

    def _build_options(first, second)
      options = { outputs: 1 }

      options = options.merge(first) if first.is_a? Hash
      options = options.merge(second) if second.is_a? Hash

      options[:outputs] = first if first.is_a? Numeric
      options[:outputs] = second if second.is_a? Numeric

      if options[:outputs]
        outputs = options[:outputs]
        options.delete(:outputs)
      end

      { options: options, outputs: outputs }
    end

    def _ensure_min_version!(purpose, lua, jit = nil)
      version = lua
      version = jit if meta.interpreter[/jit/] && jit

      return unless Gem::Version.new(
        meta.interpreter.gsub(/.+:/, '')
      ) < Gem::Version.new(version)

      message = "#{purpose} requires Lua >= #{lua}"
      message = "#{message} or LuaJIT >= #{jit}" if jit

      raise SweetMoon::Errors::SweetMoonError,
            "#{message}; Current: #{meta.runtime} (#{meta.interpreter})"
    end

    def _unsafely_destroy
      @controller[:destroy!].(@api, @interpreter, state)
      @state = nil
    end

    def inspect
      output = "#<#{self.class}:0x#{format('%016x', object_id)}"

      variables = ['@meta'].map do |struct_name|
        "#{struct_name}=#{instance_variable_get(struct_name).inspect}"
      end

      "#{output} #{variables.join(' ')}>"
    end

    private

    def build_api_meta(api_component)
      global_ffi = Component::Default.instance.options[:global_ffi]

      unless api_component[:meta][:options][:global_ffi].nil?
        global_ffi = api_component[:meta][:options][:global_ffi]
      end

      {
        api_reference: api_component[:meta][:elected][:api_reference],
        shared_objects: api_component[:meta][:elected][:shared_objects],
        global_ffi: global_ffi
      }
    end

    def build_meta(api_component, interpreter_component)
      meta_data = build_api_meta(api_component)

      meta_data[:interpreter] = interpreter_component[:meta][:elected][:interpreter]
      meta_data[:runtime] = interpreter_component[:meta][:runtime][:lua]

      @meta = Struct.new(*meta_data.keys).new(*meta_data.values)
    end

    def state
      unless @state
        raise SweetMoon::Errors::SweetMoonError,
              'The state no longer exists.'
      end

      @state
    end
  end
end
