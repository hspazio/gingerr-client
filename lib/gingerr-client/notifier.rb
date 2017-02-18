module Gingerr
  class Notifier
    def initialize(config)
      @config = config
    end

    def notify_success!
      signal = SuccessSignal.new
      notify_signal(signal)
      signal
    end

    def notify_error!(exception)
      signal = ErrorSignal.new(exception)
      notify_signal(signal)
      signal
    end

    private

    def notify_signal(signal)
      response = http_post(signals_uri, signal.to_json)
      validate_response(response)
    rescue Exception => error
      @config.logger.error("#{error.class}: #{error.message}")
    end

    def signals_uri
      URI("#{@config.host}/apps/#{@config.app_id}/signals.json")
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
end
