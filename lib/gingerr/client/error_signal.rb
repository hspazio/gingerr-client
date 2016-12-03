module Gingerr
  module Client
    class ErrorSignal < SuccessSignal
      Error = Struct.new(:name, :message, :file, :backtrace)

      attr_reader :error

      def initialize(error)
        super()
        @error = Error.new(
            error.class.name,
            error.message,
            file_from_backtrace(error.backtrace),
            error.backtrace.join("\n"))
      end

      def to_h
        super.merge({
            error: error.to_h
        })
      end

      private

      def file_from_backtrace(backtrace)
        file_path = backtrace.first.split(/:\d+:/).first
        File.basename(file_path)
      end
    end
  end
end