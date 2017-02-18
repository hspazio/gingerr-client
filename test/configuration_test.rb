require 'test_helper'

describe Gingerr::Config do
  before do
    @config = Gingerr::Config.new
  end

  it 'sets and get the app_id' do
    @config.app_id = '123'
    assert_equal '123', @config.app_id
  end

  it 'sets and get the host' do
    @config.host = 'http://localhost:8080'
    assert_equal 'http://localhost:8080', @config.host
  end

  it 'sets and get the access_token' do
    @config.access_token = '123abc'
    assert_equal '123abc', @config.access_token
  end

  it 'sets and get the logger' do
    @config.logger = 'the-logger'
    assert_equal 'the-logger', @config.logger
  end
end
