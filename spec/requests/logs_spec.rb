require 'spec_helper'

def mock_logfile
	file = File.new("#{Rails.root}/tmp/cascade.log","r")
	logfile = ActionDispatch::Http::UploadedFile.new(
	      :filename => "cascade.log", 
	      :type => "text/x-log", 
	      :head => "Content-Disposition: form-data;
	                name=\"logfile\"; 
	                filename=\"cascade.log\" 
	                Content-Type: text/x-log\r\n",
	      :tempfile => file)
	return logfile
end

describe "Logs" do

	before do
		@log = Log.create :logfile => mock_logfile 
		@log.logfile = File.open(Rails.root.join('tmp','cascade.log'))
		@log.save!
		@log.labels.create :name => 'Default Log label'

		# Simulate user login...
		visit root_path
		fill_in 'Username', :with => ENV['GITHUB_APIUSER']
		click_button 'Login'
	end

	describe "GET /logs" do
		it "display some logs" do
			visit logs_path

			page.should have_content 'cascade.log'
		end

		it "creates a new log" do
			visit new_log_path

			attach_file 'log[logfile]', Rails.root.to_s + '/tmp/cascade.log'
			click_button 'Save'

			current_path.should == new_log_path

			page.should have_content 'Success!'
		end
	end

	describe "PUT /logs" do
		it "edits a log" do
			visit edit_log_path @log

			attach_file 'log[logfile]', Rails.root.to_s + '/tmp/cascade.log'
			click_button 'Save'

			current_path.should == edit_log_path(@log)

			page.should have_content 'Success!'
		end
	end

	describe "DELETE /logs" do
		it "should delete a log" do
			visit logs_path

			find("#log_#{@log.id}").click_link 'Delete log'

			page.should have_content 'Log has been deleted.'
			page.should have_no_content 'cascade.log'
		end
	end
end
