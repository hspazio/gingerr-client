require 'test_helper'

FakeResponse = Struct.new(:code, :body) do
  def []
    'location/test/signal/123'
  end
end

describe Gingerr do
  before do
    @logger = Minitest::Mock.new
    @host = 'http://localhost:3000/gingerr'
    @app_id = ENV['APP_ID']
    Gingerr.configure do |config|
      config.host = @host
      config.app_id = @app_id
      config.logger = @logger
    end
  end

  it 'has a version' do
    assert !Gingerr::VERSION.empty?
  end

  describe '#configure' do
    it 'yields a configuration object' do
      Gingerr.configure do |config|
        assert_kind_of Gingerr::Config, config
      end
    end
  end

  describe '#notify_success!' do
    it 'sends a success signal by delegating to the notifier' do
      signal = Gingerr.notify_success!

      assert_kind_of Gingerr::SuccessSignal, signal
      assert_equal true, signal.pid > 0
      assert_match(/\d+\.\d+\.\d+\.\d+/, signal.ip)
      assert_equal false, signal.login.empty?
      assert_equal false, signal.hostname.empty?
    end

    it 'logs any errors' do
      @logger = Minitest::Mock.new
      @host = 'http://does/not/exists'
      @app_id = ENV['APP_ID']
      Gingerr.configure do |config|
        config.host = @host
        config.app_id = @app_id
        config.logger = @logger
      end

      error_message = "SocketError: Failed to open TCP connection to does:80 (getaddrinfo: nodename nor servname provided, or not known)"
      @logger.expect(:error, nil, [error_message])
      Gingerr.notify_success!
      @logger.verify
    end
  end

  describe '#notify_error!' do
    it 'sends an error signal' do
      begin
        raise StandardError, 'oops!'
      rescue => error
        @error = error
      end

      signal = Gingerr.notify_error!(@error)

      assert_kind_of Gingerr::ErrorSignal, signal
      assert_equal true, signal.pid > 0
      assert_match(/\d+\.\d+\.\d+\.\d+/, signal.ip)
      assert_equal false, signal.login.empty?
      assert_equal false, signal.hostname.empty?
    end

    it 'logs any errors' do
      @logger = Minitest::Mock.new
      @host = 'http://does/not/exists'
      @app_id = ENV['APP_ID']
      Gingerr.configure do |config|
        config.host = @host
        config.app_id = @app_id
        config.logger = @logger
      end

      begin
        raise StandardError, 'oops!'
      rescue => error
        @error = error
      end

      error_message = "SocketError: Failed to open TCP connection to does:80 (getaddrinfo: nodename nor servname provided, or not known)"
      @logger.expect(:error, nil, [error_message])
      Gingerr.notify_error!(@error)
      @logger.verify
    end
  end  
end
