require './logic/api'

RSpec.describe do
  it do
    expect(Logic::API.keys).to eq([:candidates])

    expect(Logic::API[:candidates].keys).to eq(['3.2.2', '4.0.1', '5.0.3', '5.1.4', '5.4.2'])

    expect(Logic::API[:candidates]['5.4.2'].keys).to eq(%i[version signatures])

    expect(
      Logic::API[:candidates]['5.4.2'][:signatures].keys
    ).to eq(%i[functions macros])

    expect(Logic::API[:candidates]['5.4.2'][:signatures][:functions].size).to be > 100

    expect(Logic::API[:candidates]['5.4.2'][:signatures][:macros].size).to be > 50
  end
end
