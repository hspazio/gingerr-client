require 'test_helper'

class Gingerr::ErrorSignalTest < Minitest::Test
  describe Gingerr::Client::ErrorSignal do
    before do
      begin
        raise StandardError, 'something went wrong'
      rescue => error
        @error = error
      end

      @signal = Gingerr::Client::ErrorSignal.new(@error)
    end

    it 'has a PID' do
      assert_equal $$, @signal.pid
    end

    it 'has a login' do
      assert_equal false, @signal.login.empty?
    end

    it 'has a hostname' do
      assert_equal false, @signal.hostname.empty?
    end

    it 'has an IP address' do
      assert_match(/\d+.\d+.\d+.\d+/, @signal.ip)
    end

    it 'has information about the error' do
      error = @signal.error
      assert_equal @error.class.name, error.name
      assert_equal @error.message, error.message
      assert_equal File.basename(__FILE__), error.file
      assert_equal @error.backtrace.join("\n"), error.backtrace
    end

    it 'responds to to_json' do
      params = @signal.to_json
      params = JSON.parse(params, symbolize_names: true)
      assert_equal $$, params[:pid]
      assert_equal false, params[:login].empty?
      assert_equal false, params[:hostname].empty?
      assert_match(/\d+.\d+.\d+.\d+/, params[:ip])

      assert_equal @error.class.name, params[:error][:name]
      assert_equal @error.message, params[:error][:message]
      assert_equal File.basename(__FILE__), params[:error][:file]
      assert_equal @error.backtrace.join("\n"), params[:error][:backtrace]
    end
  end
end
