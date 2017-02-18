$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'gingerr-client'
require 'minitest/autorun'

ENV['test'] ||= 'true'
ENV['APP_ID'] ||= '63292507'
