require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  it 'Multiple shared objects', :skip do
    config = YAML.load_file('config/tests.yml')

    api = SweetMoon::API.new(
      shared_objects: config['4.0.1']['shared_objects']
    )

    expect(api.respond_to?(:lua_open)).to be(true)
    expect(api.respond_to?(:lua_baselibopen)).to be(true)
  end
end
