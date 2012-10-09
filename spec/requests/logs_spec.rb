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
	end

	describe "GET /logs" do
		it "display some logs" do
			visit logs_path
			
			page.should have_content 'cascade.log'
		end

		it "creates a new log" do
			visit logs_path

			attach_file 'log[logfile]', Rails.root.to_s + '/tmp/cascade.log'
			click_button 'Upload'

			current_path.should == logs_path

			page.should have_content 'Success!'

			#save_and_open_page
		end
	end

	describe "PUT /logs" do

		it "edits a log" do
			visit logs_path

			click_link 'Edit log'

			current_path.should == edit_log_path(@log)

			attach_file 'log[logfile]', Rails.root.to_s + '/tmp/cascade.log'
			click_button 'Upload'

			current_path.should == logs_path

			page.should have_content 'Success!'
		end

		it "should not update an empty log" do
			visit logs_path

			click_link 'Edit'
			click_button 'Upload'

			current_path.should == edit_log_path(@log)

			page.should have_content 'Oops!'
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
