require 'test_helper'
require 'ostruct'

class Gingerr::ClientTest < Minitest::Test
  describe Gingerr::Client do
  	before do
      @client = Gingerr::Client
  	end

  	it 'has a version' do
      assert @client::VERSION
  	end

  	it 'allows to set the API host' do
      assert @client.host = 'http://localhost/4567'
  	end

  	it 'allows to add error callbacks to the list' do
      @client.on_error do |_|
        # NOOP
      end
      refute_empty @client.callbacks[:error]
  	end

  	it 'allows to add success callbacks to the list' do
      @client.on_success do
        # NOOP
      end
      refute_empty @client.callbacks[:success]
  	end

  	describe '#signal' do
  	  before do
        @client.host = 'http://localhost:3000/gingerr'
        @client.app_id = 123
  	  end

  	  it 'sends a success signal if no errors raised' do
        signal = Gingerr::Client::SuccessSignal.new

  	  	http_mock = Minitest::Mock.new
  	  	http_mock.expect(
            :post_form,
            true,
            [URI("#{@client.host}/apps/#{@client.app_id}/signals.json"), signal.to_h])

        signal = @client.signal(http_client: http_mock)

        assert_equal Gingerr::Client::SuccessSignal, signal.class
        http_mock.verify
      end

      it 'sends an error signal if any errors raised' do
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
            [URI("#{@client.host}/apps/#{@client.app_id}/signals.json"), signal.to_h])

        signal = @client.signal(@error, http_client: http_mock)

        assert_equal Gingerr::Client::ErrorSignal, signal.class
        http_mock.verify
      end
  	end

   describe '#success' do
     before do
        @client.host = 'http://localhost:3000/gingerr'
        @client.app_id = 123
      end

      it 'sends a success signal' do
        signal = Gingerr::Client::SuccessSignal.new

        http_mock = Minitest::Mock.new
        http_mock.expect(
            :post_form,
            true,
            [URI("#{@client.host}/apps/#{@client.app_id}/signals.json"), signal.to_h])

        signal = @client.success(http_client: http_mock)

        assert_equal Gingerr::Client::SuccessSignal, signal.class
        http_mock.verify
      end
    end

    describe '#error' do
     before do
        @client.host = 'http://localhost:3000/gingerr'
        @client.app_id = 123
      end

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
            [URI("#{@client.host}/apps/#{@client.app_id}/signals.json"), signal.to_h])

        parameters = { custom_param_1: 'param 1', custom_param_2: 'param 2' }
        signal = @client.error(@error, http_client: http_mock, parameters: parameters)

        assert_equal Gingerr::Client::ErrorSignal, signal.class
        http_mock.verify
      end
    end  
  end
end
