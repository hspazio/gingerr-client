require 'test_helper'

class Gingerr::SuccessSignalTest < Minitest::Test
  describe Gingerr::Client::SuccessSignal do
    before do
      @signal = Gingerr::Client::SuccessSignal.new
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

    it 'responds to to_h' do
      params = @signal.to_h
      assert_equal $$, params[:pid]
      assert_equal false, params[:login].empty?
      assert_equal false, params[:hostname].empty?
      assert_match(/\d+.\d+.\d+.\d+/, params[:ip])
      assert_nil params[:error]
    end
  end
end
