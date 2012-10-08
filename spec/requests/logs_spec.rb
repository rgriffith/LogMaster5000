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
			fill_in 'Logfile', :with => 'cascade-create.log'
			click_button 'Create Log'

			current_path.should == logs_path
			page.should have_content 'cascade-create.log'

			#save_and_open_page
		end
	end

	describe "PUT /logs" do
		it "edits a log" do
			visit logs_path
			click_link 'Edit'

			current_path.should == edit_log_path(@log)

			#save_and_open_page

			find_field('Logfile').value.should == 'cascade.log'

			fill_in 'Logfile', :with => 'cascade-updated.log'
			click_button 'Update Log'

			current_path.should == logs_path

			page.should have_content 'cascade-updated.log'
		end

		it "should not uupdate an empty log" do
			visit logs_path
			click_link 'Edit'

			fill_in 'Logfile', :with => ''
			click_button 'Update Log'

			current_path.should == edit_log_path(@log)
			page.should have_content 'There was an error updating log.'
		end
	end

	describe "DELETE /logs" do
		it "should delete a log" do
			visit logs_path
			find("#log_#{@log.id}").click_link 'Delete'
			page.should have_content 'Log has been deleted.'
			page.should have_no_content 'cascade.log'
		end
	end
end
