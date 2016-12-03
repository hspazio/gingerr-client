require 'gingerr/client/version'
require 'gingerr/client/report'
require 'gingerr/client/success_signal'
require 'gingerr/client/error_signal'
require 'net/http'
require 'socket'
require 'pathname'

module Gingerr
  module Client
    at_exit do
      unless ENV['test'] == 'true'
        puts $!
        report!
      end
    end

    class << self
      attr_accessor :host
      attr_accessor :app_id
      
      def on_error(&callback)
        callbacks[:error] << callback
      end
  
      def on_success(&callback)
        callbacks[:success] << callback
      end
  
      def report!(error: $!, http_client: Net::HTTP)
        signal = create_signal(error)
        run_callbacks(error)
        send_signal(http_client, signal)
        signal
      end

      def create_signal(error)
        if error
          ErrorSignal.new(error)
        else
          SuccessSignal.new
        end
      end

      def run_callbacks(error)
        if error
          callbacks[:error].each { |callback| callback.call(error) }
        else
          callbacks[:success].each { |callback| callback.call }
        end
      end
  
      def callbacks
        @callbacks ||= { error: [], success: [] }
      end

      def send_signal(http_client, signal)
        new_signal_uri = URI("#{host}/apps/#{app_id}/signals.json")
        http_client.post_form(new_signal_uri, signal.to_h)
        # unless response.code = '201'

      end
    end
  
    # TODO: just a sketch. Require tests
    # class Interceptor
  
    #   def on_error(*errors, &callback)
    #     errors ||= StandardError
    #     error_callbacks << [Array(errors), callback]
    #   end
  
    #   def on_success(&callback)
    #     success_callbacks << callback
    #   end
  
    #   def report(on_success: ->{}, on_error: ->(*){}, &block)
    #     block.call
    #   rescue => error
    #     on_error.call(error)
    #     callback = callback_by_error(error)
    #     callback.call(error)
    #     raise
    #   else
    #     on_success.call
    #     success_callbacks.each { |c| c.call }
    #   end
  
    #   private
  
    #   def error_callbacks
    #     @error_callbacks ||= []
    #   end
  
    #   def success_callbacks
    #     @success_callbacks ||= []
    #   end
  
    #   def callback_by_error(error)
    #     _, callback = error_callbacks.find{ |errors, _| errors.find { |err_class| error <= err_class } }
    #     callback
    #   end
    # end
  end
end

