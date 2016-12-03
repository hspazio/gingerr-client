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

  	describe '#report!' do
  	  before do
        @client.host = 'http://localhost:3000/gingerr'
        @client.app_id = 123
  	  end

  	  it 'creates a success report if no errors raised' do
        signal = Gingerr::Client::SuccessSignal.new

  	  	http_mock = Minitest::Mock.new
  	  	http_mock.expect(
            :post_form,
            true,
            [URI("#{@client.host}/apps/#{@client.app_id}/signals.json"), signal.to_h])

        signal = @client.report!(http_client: http_mock)

        assert_equal Gingerr::Client::SuccessSignal, signal.class
        http_mock.verify
      end

      it 'creates an error report if any errors raised' do
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

        signal = @client.report!(error: @error, http_client: http_mock)

        assert_equal Gingerr::Client::ErrorSignal, signal.class
        http_mock.verify
      end
  	end
  end
end
