require 'spec_helper'

describe "Labels" do

	before do		
		@label = Label.create :name => 'Default label'

		# Simulate user login...
		visit root_path
		fill_in 'Username', :with => ENV['GITHUB_APIUSER']
		click_button 'Login'
	end

	describe "GET /labels" do
		it "display some labels" do	
			visit labels_path

			page.should have_content 'Default label'
		end
	end

	describe "GET /labels/new" do	
		it "creates a new label" do
			visit new_label_path

			fill_in 'Name', :with => 'New Label'
			click_button 'Save'

			current_path.should == labels_path

			page.should have_content 'Success!'
		end

		it "should not create a new label with reserved name" do
			visit new_label_path

			fill_in 'Name', :with => 'new'
			click_button 'Save'

			current_path.should == new_label_path

			page.should have_content 'Oops!'
		end
	end

	describe "PUT /labels" do
		it "should not update a label with an empty name" do
			visit edit_label_path @label

			fill_in 'Name', :with => ''
			click_button 'Save'

			current_path.should == edit_label_path(@label)

			page.should have_content 'Oops!'
		end

		it "should not update a label with a reserved name" do
			visit edit_label_path @label

			fill_in 'Name', :with => 'new'
			click_button 'Save'

			current_path.should == edit_label_path(@label)

			page.should have_content 'Oops!'
		end
	end

	describe "DELETE /labels" do
		it "should delete a label" do
			visit labels_path

			find("#label_#{@label.id}").click_link 'Delete label'

			page.should have_content 'Label has been deleted.'
			page.should have_no_content 'Default label'
		end
	end
end
