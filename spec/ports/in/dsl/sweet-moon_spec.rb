require './ports/in/dsl/sweet-moon'

RSpec.describe do
  it do
    expect(SweetMoon.meta.version).to eq('0.0.2')

    config = YAML.load_file('config/tests.yml')['5.4.4']

    state = SweetMoon::State.new(shared_object: config['shared_object'])

    expect(state.eval('return 1.5 + 1.5;')).to eq(3.0)
  end
end
