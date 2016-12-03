module Gingerr
  module Client
    class SuccessSignal
      attr_reader :pid, :login, :hostname, :ip
      def initialize
        @pid = Process.pid
        @login = ENV['USER'] || ENV['USERNAME']
        @hostname = Socket.gethostname
        @ip = find_ip_address
      end

      def to_h
        { pid: pid,
          login: login,
          hostname: hostname,
          ip: ip }
      end

      private

      def find_ip_address
        Socket.ip_address_list.find{ |ip| ip.ipv4_private? }.ip_address
      end
    end
  end
end