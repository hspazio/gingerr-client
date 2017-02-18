require 'test_helper'
require 'ostruct'

FakeResponse = Struct.new(:code, :body) do
  def []
    'location/test/signal/123'
  end
end

class Gingerr::ClientTest < Minitest::Test
  describe Gingerr::Client do
    before do
      @client = Gingerr::Client.new(
        host: 'http://localhost:3000/gingerr',
        app_id: ENV['APP_ID']
      )
    end

    it 'has a version' do
      assert !Gingerr::Client::VERSION.empty?
    end

    describe '#notify_success!' do
      it 'sends a success signal' do
        signal = Gingerr::Client::SuccessSignal.new

        http_mock = Minitest::Mock.new
        http_mock.expect(
          :post_form,
          true,
          [URI("#{@client.host}/apps/#{@client.app_id}/signals.json"), signal.to_h]
        )

        # signal = @client.notify_success!(http_client: http_mock)
        signal = @client.notify_success!

        assert_equal Gingerr::Client::SuccessSignal, signal.class
        # http_mock.verify
      end

      it 'raises ServerError if unexpected errors' do
        def @client.http_post(*args)
          FakeResponse.new(500, 'something went wrong')
        end

        assert_raises Gingerr::Client::ServerError do
          @client.notify_success!
        end
      end

      it 'raises ClientError if wrong params' do
        def @client.http_post(*args)
          FakeResponse.new(400, 'something went wrong')
        end

        assert_raises Gingerr::Client::ClientError do
          @client.notify_success!
        end
      end
    end

    describe '#notify_error!' do
      it 'sends an error signal' do
        begin
          raise StandardError, 'oops!'
        rescue => error
          @error = error
        end

        signal = Gingerr::Client::ErrorSignal.new(@error)

        http_mock = Minitest::Mock.new
        http_mock.expect(
          :post_form,
          true,
          [URI("#{@client.host}/apps/#{@client.app_id}/signals.json"), signal.to_json]
        )

        parameters = { custom_param_1: 'param 1', custom_param_2: 'param 2' }
        # signal = @client.notify_error!(@error, http_client: http_mock, parameters: parameters)
        signal = @client.notify_error!(@error)

        assert_equal Gingerr::Client::ErrorSignal, signal.class
        # http_mock.verify
      end

      it 'raises ServerError if unexpected errors' do
        def @client.http_post(*args)
          FakeResponse.new(500, 'something went wrong')
        end

        assert_raises Gingerr::Client::ServerError do
          @client.notify_success!
        end
      end

      it 'raises ClientError if wrong params' do
        def @client.http_post(*args)
          FakeResponse.new(400, 'something went wrong')
        end

        assert_raises Gingerr::Client::ClientError do
          @client.notify_success!
        end
      end
    end  
  end
end
