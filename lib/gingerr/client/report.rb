module Gingerr
  module Client
    class Report
      attr_reader :created_at, :pid, :command
      attr_accessor :state

      def initialize
        @created_at = Time.now
        @pid = $$
        @command = $0
      end

      def to_h
        { pid: pid, 
          state: state, 
          command: command, 
          created_at: created_at }
      end
    end
  end
end
