require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  context 'local' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(shared_object: config['5.4.2']['shared_object'])

      expect(state.eval('return 1 + 2')).to eq(3)

      expect(state.add_package_path(config['5.4.2']['fennel'])).to eq(nil)

      expect(state.package_path).to include(config['5.4.2']['fennel'])

      expect(state.eval('return 1 + 2')).to eq(3)

      expect(state.require_module(:fennel)).to eq(nil)
      expect(state.eval('return 1 + 2')).to eq(3)

      expect(state.eval('return fennel.eval("(+ 1 1)");')).to eq(2)

      fennel = state.eval('return fennel')

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

      expect(state.eval('return fennel.eval("(+ 1 1)");')).to eq(2)

      expect(state.eval('return fennel.eval("(+ 1 1)");')).to eq(2)

      expect(fennel.values.map(&:class).map(&:to_s).sort).to eq(
        %w[Array Hash Hash Hash Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc
           Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc
           Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc Proc String
           String String]
      )

      expect(state.eval('return fennel.eval("(+ 1 1)");')).to eq(2)

      expect(fennel['eval'].(['(+ 4 5)'])).to eq(9)

      expect(fennel['dofile'].(['spec/dsl/examples/read.fnl'])).to eq({ 'b' => 2 })

      expect(state.get(:a)).to eq(1)

      expect(state.require_module_as('fennel', 'f')).to eq(nil)

      expect(state.eval('return f.eval("(+ 2 3)");')).to eq(5)

      expect(state.get(:f, :version)).to eq('1.0.0')
      expect(state.eval('return f.eval("(+ 2 3)");')).to eq(5)
      expect(state.get(:f, :lorem)).to eq(nil)
      expect(state.eval('return f.eval("(+ 2 3)");')).to eq(5)

      expect(state.get(:f, :eval).(['(+ 2 2)'])).to eq(4)

      expect(state.add_package_cpath('/lib/lib.so')).to eq(nil)
      expect(state.package_cpath).to include('/lib/lib.so')
    end
  end

  context 'constructor' do
    it do
      config = YAML.load_file('config/tests.yml')

      state = SweetMoon::State.new(
        shared_object: config['5.4.2']['shared_object'],
        package_path: 'fennel.lua',
        package_cpath: 'lib.so'
      )

      expect(state.package_path).to include('fennel.lua')

      expect(state.package_cpath).to include('lib.so')
    end
  end

  context 'global' do
    it do
      SweetMoon.global.clear

      config = YAML.load_file('config/tests.yml')

      SweetMoon.global.config(
        shared_object: config['5.4.2']['shared_object'],
        package_path: 'fennel.lua',
        package_cpath: 'lib.so'
      )

      expect(SweetMoon.global.state.package_path).to include('fennel.lua')

      expect(SweetMoon.global.state.package_cpath).to include('lib.so')
    end
  end
end
