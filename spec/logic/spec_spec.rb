require './logic/spec'

RSpec.describe do
  it do
    expect(Logic::Spec[:name]).to eq 'sweet-moon'
    expect(Logic::Spec[:command]).to eq 'sweet-moon'
  end
end
