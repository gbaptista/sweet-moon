require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  context 'fennel' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(
        shared_object: config['5.4.2']['shared_object'],
        package_path: config['5.4.2']['fennel']
      )

      config['luarocks'].each { |path| state.add_package_path(path) }

      expect(state.eval('return 1 + 1')).to eq(2)

      fennel = state.eval('return require("fennel")')

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(fennel.keys.sort).to eq(
        ['comment', 'comment?', 'compile', 'compile-stream', 'compile-string',
         'compile1', 'compileStream', 'compileString', 'doc', 'dofile', 'eval',
         'gensym', 'granulate', 'list', 'list?', 'load-code', 'loadCode',
         'macro-loaded', 'macro-path', 'macro-searchers', 'macroLoaded',
         'make-searcher', 'makeSearcher', 'make_searcher', 'mangle', 'metadata',
         'parser', 'path', 'repl', 'scope', 'search-module', 'searchModule',
         'searcher', 'sequence', 'sequence?', 'string-stream', 'stringStream',
         'sym', 'sym-char?', 'sym?', 'syntax', 'traceback', 'unmangle', 'varg',
         'version', 'view']
      )

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(fennel.values.map(&:class).map(&:to_s).sort).to eq(
        %w[Array Hash Hash Hash Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc
           Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc
           Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc String
           String String]
      )

      expect(state.eval('return 1 + 1')).to eq(2)
    end
  end

  context 'supernova' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.4.2']['shared_object'])

      config['luarocks'].each { |path| state.add_package_path(path) }

      expect(state.eval('return 1 + 1')).to eq(2)

      supernova = state.eval('return require("supernova")')

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(supernova.keys.sort).to eq(
        %w[active_theme apply_command chain colors disable enable enabled get-theme
           get_theme handlers init is_controller set-colors set-theme set_colors
           set_theme styles]
      )

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(supernova.values.map(&:class).map(&:to_s).sort).to eq(
        %w[Hash Hash Hash Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc String
           String TrueClass TrueClass]
      )

      expect(state.eval('return 1 + 1')).to eq(2)
    end
  end

  context 'dkjson' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.4.2']['shared_object'])

      config['luarocks'].each { |path| state.add_package_path(path) }

      expect(state.eval('return 1 + 1')).to eq(2)

      dkjson = state.eval('return require("dkjson")')

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(dkjson.keys.sort).to eq(
        %w[addnewline decode encode encodeexception null quotestring use_lpeg version]
      )

      expect(state.eval('return 1 + 1')).to eq(2)

      expect(dkjson.values.map(&:class).map(&:to_s).sort).to eq(
        %w[Hash Proc Proc Proc Proc Proc Proc String]
      )

      expect(state.eval('return 1 + 1')).to eq(2)
    end
  end
end
