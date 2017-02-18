require 'gingerr-client/version'
require 'gingerr-client/configuration'
require 'gingerr-client/notifier'
require 'gingerr-client/error'
require 'gingerr-client/success_signal'
require 'gingerr-client/error_signal'
require 'net/http'
require 'json'
require 'socket'
require 'pathname'

module Gingerr
  class ClientError < StandardError; end
  class ServerError < StandardError; end

  @notifiers = {}

  def self.configure(app = :default)
    config = Gingerr::Config.new
    yield config
    @notifiers[app] = Notifier.new(config)
  end

  def self.notify_success!(app = :default)
    @notifiers.fetch(app).notify_success!
  end

  def self.notify_error!(app = :default, exception)
    @notifiers.fetch(app).notify_error!(exception)
  end

  # TODO: just a sketch. Require tests
  # def on_error(&callback)
  #   callbacks[:error] << callback
  # end
  #
  # def on_success(&callback)
  #   callbacks[:success] << callback
  # end
  #
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
