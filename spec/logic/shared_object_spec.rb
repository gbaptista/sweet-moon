require './logic/shared_object'

RSpec.describe do
  before do
    @candidate_paths = [
      '/usr/lib/liblua.so',
      '/usr/lib/liblua.so.5.2',
      '/usr/lib/liblua.so.5.2.4',
      '/usr/lib/liblua.so.5.3',
      '/usr/lib/liblua.so.5.3.6',
      '/usr/lib/liblua.so.5.4',
      '/usr/lib/liblua.so.5.4.4',
      '/usr/lib/liblua5.2.so',
      '/usr/lib/liblua5.2.so.5.2',
      '/usr/lib/liblua5.2.so.5.2.4',
      '/usr/lib/liblua5.3.so',
      '/usr/lib/liblua5.3.so.5.3',
      '/usr/lib/liblua5.3.so.5.3.6',
      '/usr/lib/liblua5.4.so',
      '/usr/lib/libluajit-5.1.so',
      '/usr/lib/libluajit-5.1.so.2',
      '/usr/lib/libluajit-5.1.so.2.1.0'
    ]
  end

  context 'normalize' do
    it do
      expect(
        Logic::SharedObject[:normalize].('/lua/lua-5.4.2_Linux54_64_lib/liblua54.20.so')
      ).to eq(
        { path: '/lua/lua-5.4.2_Linux54_64_lib/liblua54.20.so',
          inferences: { jit: false, version: '5.4.2.0' } }
      )

      expect(
        Logic::SharedObject[:normalize].('/lua/lua-5.4.2_Linux54_64_lib/liblua54.so')
      ).to eq(
        { path: '/lua/lua-5.4.2_Linux54_64_lib/liblua54.so',
          inferences: { jit: false, version: '5.4' } }
      )

      expect(
        Logic::SharedObject[:normalize].('/usr/lib/liblua5.so.5.2.so.5.2.4')
      ).to eq(
        { path: '/usr/lib/liblua5.so.5.2.so.5.2.4',
          inferences: { jit: false, version: '5.2.4' } }
      )

      expect(
        Logic::SharedObject[:normalize].('/usr/lib/liblua5.so')
      ).to eq(
        { path: '/usr/lib/liblua5.so', inferences: { jit: false, version: '5' } }
      )

      expected_result = [
        { path: '/usr/lib/liblua.so', inferences: { jit: false, version: nil } },
        { path: '/usr/lib/liblua.so.5.2', inferences: { jit: false, version: '5.2' } },
        { path: '/usr/lib/liblua.so.5.2.4', inferences: { jit: false, version: '5.2.4' } },
        { path: '/usr/lib/liblua.so.5.3', inferences: { jit: false, version: '5.3' } },
        { path: '/usr/lib/liblua.so.5.3.6', inferences: { jit: false, version: '5.3.6' } },
        { path: '/usr/lib/liblua.so.5.4', inferences: { jit: false, version: '5.4' } },
        { path: '/usr/lib/liblua.so.5.4.4', inferences: { jit: false, version: '5.4.4' } },
        { path: '/usr/lib/liblua5.2.so', inferences: { jit: false, version: '5.2' } },
        { path: '/usr/lib/liblua5.2.so.5.2', inferences: { jit: false, version: '5.2' } },
        { path: '/usr/lib/liblua5.2.so.5.2.4', inferences: { jit: false, version: '5.2.4' } },
        { path: '/usr/lib/liblua5.3.so', inferences: { jit: false, version: '5.3' } },
        { path: '/usr/lib/liblua5.3.so.5.3', inferences: { jit: false, version: '5.3' } },
        { path: '/usr/lib/liblua5.3.so.5.3.6', inferences: { jit: false, version: '5.3.6' } },
        { path: '/usr/lib/liblua5.4.so', inferences: { jit: false, version: '5.4' } },
        { path: '/usr/lib/libluajit-5.1.so', inferences: { jit: true, version: '5.1' } },
        { path: '/usr/lib/libluajit-5.1.so.2', inferences: { jit: true, version: '5.1' } },
        { path: '/usr/lib/libluajit-5.1.so.2.1.0', inferences: { jit: true, version: '5.1' } }
      ]

      expect(
        @candidate_paths.map { |path| Logic::SharedObject[:normalize].(path) }
      ).to eq(expected_result)
    end
  end

  context 'choose' do
    it do
      expect(Logic::SharedObject[:choose].(@candidate_paths)).to eq(
        [{ path: '/usr/lib/liblua.so.5.4.4', inferences: { jit: false, version: '5.4.4' } }]
      )

      expect(Logic::SharedObject[:choose].(@candidate_paths, jit: true)).to eq(
        [{ path: '/usr/lib/libluajit-5.1.so', inferences: { version: '5.1', jit: true } }]
      )

      expect(Logic::SharedObject[:choose].(@candidate_paths, version: '5.1')).to eq(
        [{ path: '/usr/lib/libluajit-5.1.so', inferences: { version: '5.1', jit: true } }]
      )

      expect(Logic::SharedObject[:choose].(@candidate_paths, version: '5.2')).to eq(
        [{ path: '/usr/lib/liblua.so.5.2.4', inferences: { version: '5.2.4', jit: false } }]
      )

      expect(Logic::SharedObject[:choose].(@candidate_paths, version: '5')).to eq(
        [{ path: '/usr/lib/liblua.so.5.4.4', inferences: { version: '5.4.4', jit: false } }]
      )

      expect(
        Logic::SharedObject[:choose].(@candidate_paths, jit: false, version: '5.1')
      ).to eq(
        []
      )

      expect(
        Logic::SharedObject[:choose].(@candidate_paths, jit: true, version: '5')
      ).to eq(
        [{ path: '/usr/lib/libluajit-5.1.so', inferences: { version: '5.1', jit: true } }]
      )
    end
  end
end
