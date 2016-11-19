require 'test_helper'

module Gingerr
  module Client
    class ReportTest < Minitest::Test
      describe Gingerr::Client::Report do
        before do
          @report = Gingerr::Client::Report.new
        end
  
        it 'has a created_at date' do
          assert_kind_of ::Time, @report.created_at
        end
  
        it 'has a PID of the process' do
          current_pid = $$
          assert_equal current_pid, @report.pid
        end
  
        it 'has a command that executed the process' do
          current_command = $0
          assert_equal current_command, @report.command
        end
  
        it 'has a state defaulted to nil' do
          assert_nil @report.state
        end

        it 'has a state that can be set' do
          assert_equal :success, @report.state = :success
          assert_equal :error, @report.state = :error
        end

        it 'responds to to_h' do
          @report.state = :error
          json = @report.to_h
          
          assert json[:pid] > 0
          assert_equal :error, json[:state]
          refute_empty json[:command]
          assert_kind_of Time, json[:created_at]
        end
      end
    end
  end
end