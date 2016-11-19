require "gingerr/client/version"
require "gingerr/client/report"
require "net/http"

module Gingerr
  module Client
    at_exit do
      puts $!
      # report!
    end

    class << self
      attr_accessor :host 
      
      def on_error(&callback)
        callbacks[:error] << callback
      end
  
      def on_success(&callback)
        callbacks[:success] << callback
      end
  
      def report!(error: $!, report: Report.new, http_client: Net::HTTP)
        if error
          callbacks[:error].each { |callback| callback.call($!) }
          report.state = :error
        else
          callbacks[:success].each { |callback| callback.call }
          report.state = :success
        end
  
        send_report(http_client, report)
        report
      end
  
      def callbacks
        @callbacks ||= { error: [], success: [] }
      end

      def send_report(http_client, report)
        reports_uri = URI("#{host}/reports")
        http_client.post_form(reports_uri, report.to_h)
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

