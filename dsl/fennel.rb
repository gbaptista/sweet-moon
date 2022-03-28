module DSL
  class Fennel
    attr_reader :meta

    def initialize(state)
      @state = state

      @state.require_module(:fennel)

      @state.eval(
        'table.insert(package.loaders or package.searchers, fennel.searcher)'
      )

      @state.eval('debug.traceback = fennel.traceback')

      @eval = @state.get(:fennel, :eval)
      @dofile = @state.get(:fennel, :dofile)
      @version = @state.get(:fennel, :version)

      build_meta
    end

    def eval(input, first = nil, second = nil)
      options = _build_options(first, second)

      @eval.([input, options[:options]], options[:outputs])
    end

    def load(path, first = nil, second = nil)
      options = _build_options(first, second)

      @dofile.([path, options[:options]], options[:outputs])
    end

    def build_meta
      meta_data = @state.meta.to_h

      meta_data = meta_data.merge(
        runtime: "Fennel #{@version} on #{meta_data[:runtime]}"
      )

      @meta = Struct.new(*meta_data.keys).new(*meta_data.values)
    end

    def respond_to_missing?(method_name)
      @state.respond_to? method_name
    end

    def method_missing(method_name, *arguments, &block)
      @state.public_send(method_name, *arguments, &block)
    end
  end
end
