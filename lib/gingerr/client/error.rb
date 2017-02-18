module Gingerr
  class Client
    class ErrorInfo < SimpleDelegator
      def name
        __getobj__.class.name
      end

      def backtrace
        __getobj__.backtrace.join("\n")
      end

      def file
        file_path = __getobj__.backtrace.first.split(/:\d+:/).first
        File.basename(file_path)
      end

      def to_h
        {
          name: name,
          message: message,
          file: file,
          backtrace: backtrace
        }
      end
    end
  end
end
