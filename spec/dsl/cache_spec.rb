require './dsl/cache'

RSpec.describe do
  context 'cache' do
    it do
      expect(DSL::Cache.instance.cache_key_for(
               :api_module,
               { global_ffi: false, shared_objects: ['/liblua.so'] },
               %i[shared_objects api_reference global_ffi
                  interpreter package_path package_cpath]
             )).to eq('api_module|/liblua.so|nil|false|nil|nil|nil')
    end
  end
end
