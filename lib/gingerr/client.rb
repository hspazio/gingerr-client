require 'gingerr/client/version'
require 'gingerr/client/error'
require 'gingerr/client/success_signal'
require 'gingerr/client/error_signal'
require 'net/http'
require 'json'
require 'socket'
require 'pathname'

module Gingerr
  class Client
    class ClientError < StandardError; end
    class ServerError < StandardError; end

    at_exit do
      unless ENV['test'] == 'true'
        puts $!
      end
    end

    attr_reader :host, :app_id

    def initialize(host:, app_id:)
      @host = host
      @app_id = app_id
    end

    def on_error(&callback)
      callbacks[:error] << callback
    end

    def on_success(&callback)
      callbacks[:success] << callback
    end

    def notify_success!
      signal = SuccessSignal.new
      send_signal(signal)
      signal
    end

    # TODO: send 'parameters' as additional info via API
    def notify_error!(error_obj = $!, parameters: {})
      signal = ErrorSignal.new(error_obj)
      send_signal(signal)
      signal
    end

    private

    def send_signal(signal)
      uri = URI("#{host}/apps/#{app_id}/signals.json")
      response = http_post(uri, signal.to_json)
      validate_response(response)
    end

    def http_post(uri, json_params)
      request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      request.body = json_params
      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end
    end

    def validate_response(response)
      if response.code == '201'
        response['location']
      else
        if response.code.to_i >= 500
          raise ServerError, response.body
        else
          raise ClientError, response.body
        end
      end
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

