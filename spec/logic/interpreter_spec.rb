require './logic/interpreter'

RSpec.describe do
  it do
    signatures = {}

    Logic::Interpreter[:candidates]['5.4'][:requires].each do |function|
      signatures[function] = true
    end

    expect(Logic::Interpreter[:elect].(signatures, '5.4.1')).to eq(
      compatible: true, version: '5.4', missing: []
    )

    expect(Logic::Interpreter[:elect].(signatures, '5.4.1', interpreter: '3.2')).to eq(
      { compatible: false, error: 'Interpreter 3.2 not available.' }
    )

    signatures.delete(:luaL_newstate)

    result = Logic::Interpreter[:elect].(signatures, '5.4.1')

    expect(result.keys).to match(%i[compatible error])
    expect(result[:compatible]).to eq(false)
    expect(result[:error]).to match(
      /No compatible interpreter found for Lua C API 5\.4\.1/
    )

    signatures[:luaL_newstate] = true

    expect(Logic::Interpreter[:elect].(signatures, '5.4.1')).to eq(
      compatible: true, version: '5.4', missing: []
    )
  end
end
