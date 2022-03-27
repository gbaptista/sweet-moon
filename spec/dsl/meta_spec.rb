require 'yaml'

require './dsl/sweet_moon'

RSpec.describe do
  it do
    config = YAML.load_file('config/tests.yml')

    SweetMoon.global.config(shared_object: config['5.4.4']['shared_object'])

    api = SweetMoon::API.new(shared_object: config['5.4.4']['shared_object'])

    expect(api.meta.to_h).to eq(
      shared_objects: [config['5.4.4']['shared_object']],
      api_reference: '5.4.2',
      global_ffi: false
    )

    expect(api.meta.shared_objects).to eq([config['5.4.4']['shared_object']])
    expect(api.meta.api_reference).to eq('5.4.2')

    state = SweetMoon::State.new(shared_object: config['5.4.4']['shared_object'])

    expect(state.meta.to_h).to eq(
      shared_objects: [config['5.4.4']['shared_object']],
      api_reference: '5.4.2',
      interpreter: '5.4',
      runtime: 'Lua 5.4',
      global_ffi: false
    )

    expect(state.meta.shared_objects).to eq([config['5.4.4']['shared_object']])
    expect(state.meta.api_reference).to eq('5.4.2')
    expect(state.meta.interpreter).to eq('5.4')
    expect(state.meta.runtime).to eq('Lua 5.4')

    expect(SweetMoon.global.api.meta.to_h).to eq(
      shared_objects: [config['5.4.4']['shared_object']],
      api_reference: '5.4.2',
      global_ffi: false
    )

    expect(SweetMoon.global.api.meta.shared_objects).to eq(
      [config['5.4.4']['shared_object']]
    )

    expect(SweetMoon.global.api.meta.api_reference).to eq('5.4.2')

    expect(SweetMoon.global.state.meta.to_h).to eq(
      shared_objects: [config['5.4.4']['shared_object']],
      api_reference: '5.4.2',
      interpreter: '5.4',
      runtime: 'Lua 5.4',
      global_ffi: false
    )

    expect(SweetMoon.global.state.meta.shared_objects).to eq(
      [config['5.4.4']['shared_object']]
    )

    expect(SweetMoon.global.state.meta.api_reference).to eq('5.4.2')
    expect(SweetMoon.global.state.meta.interpreter).to eq('5.4')
    expect(SweetMoon.global.state.meta.runtime).to eq('Lua 5.4')
  end
end
