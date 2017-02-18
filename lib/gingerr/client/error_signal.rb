module Gingerr
  class Client
    class ErrorSignal < SuccessSignal
      attr_reader :error

      def initialize(error)
        super()
        @error = ErrorInfo.new(error)
      end

      def to_h
        super.merge(type: :error, error: error.to_h)
      end
    end
  end
end
