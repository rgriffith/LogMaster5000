require 'spec_helper'

describe "Labels" do

	before do
		@label = Label.create :name => 'Default label' 
	end

	describe "GET /labels" do
		it "display some labels" do
			visit labels_path
			
			page.should have_content 'Default label'
		end

		it "creates a new label" do
			visit labels_path

			fill_in 'Name', :with => 'New Label'
			click_button 'Save'

			current_path.should == labels_path

			page.should have_content 'Success!'
		end
	end

	describe "PUT /labels" do
		it "edits a label" do
			visit labels_path

			click_link 'Edit label'

			current_path.should == edit_label_path(@label)

			fill_in 'Name', :with => 'Updated label'
			click_button 'Save'

			current_path.should == labels_path

			page.should have_content 'Success!'
		end

		it "should not update an empty label" do
			visit labels_path

			click_link 'Edit'

			fill_in 'Name', :with => ''
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
