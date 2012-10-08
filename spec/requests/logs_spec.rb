require 'spec_helper'

describe "Logs" do
  describe "GET /logs" do
  	it "display some logs" do
  		visit logs_path
  		page.should have_content 'cascade.log'
  	end
  end
end
