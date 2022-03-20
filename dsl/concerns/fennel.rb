require_relative '../fennel'

module DSL
  module Concerns
    module Fennel
      def fennel
        _ensure_min_version!('Fennel', '5.1', '2')

        @fennel ||= DSL::Fennel.new(self)
      end
    end
  end
end
