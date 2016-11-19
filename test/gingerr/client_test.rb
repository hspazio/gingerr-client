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
        @client.host = 'http://localhost:4567'
  	  end

  	  it 'creates a success report if no errors raised' do
  	  	http_mock = Minitest::Mock.new
  	  	http_mock.expect(:post_form, true, [URI("#{@client.host}/reports"), {state: :success}])

        report = OpenStruct.new(state: nil)
        @client.report!(report: report, http_client: http_mock)

        assert_equal :success, report.state
        http_mock.verify
      end

      it 'creates an error report if any errors raised' do
      	http_mock = Minitest::Mock.new
  	  	http_mock.expect(:post_form, true, [URI("#{@client.host}/reports"), {state: :error}])

        report = OpenStruct.new(state: nil)
        error = StandardError.new('oops!')
        @client.report!(report: report, error: error, http_client: http_mock)

        assert_equal :error, report.state
        http_mock.verify
      end
  	end
  end
end
