require_relative 'signatures/signatures_322'
require_relative 'signatures/signatures_401'
require_relative 'signatures/signatures_503'
require_relative 'signatures/signatures_514'
require_relative 'signatures/signatures_542'

module Logic
  API = {
    candidates: {
      '3.2.2' => { version: '3.2.2', signatures: V322::Signatures },
      '4.0.1' => { version: '4.0.1', signatures: V401::Signatures },
      '5.0.3' => { version: '5.0.3', signatures: V503::Signatures },
      '5.1.4' => { version: '5.1.4', signatures: V514::Signatures },
      '5.4.2' => { version: '5.4.2', signatures: V542::Signatures }
    }
  }
end
