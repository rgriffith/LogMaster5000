class ApplicationController < ActionController::Base
	protect_from_forgery

	helper_method :current_user
	helper_method :organization_member
	helper_method :user_signed_in?
	helper_method :correct_user?

  	private
  		def authenticate_user!	    	
	    	if !current_user
	        	redirect_to root_url, :notice => {:type => 'error', :message => 'Sorry, but you must login before you can access this application.'}
	      	end
	    end

		def current_user
			begin
				@current_user ||= User.find(session[:user_id]) if session[:user_id]
			rescue
				nil
			end
	    end

	    def organization_member?(username)
			require 'uri'
			require 'yajl/http_stream'

			c = Curl::Easy.new("https://api.github.com/orgs/"+ENV['GITHUB_ORG']+"/members")
			c.http_auth_types = :basic
			c.username = ENV['GITHUB_APIUSER']
			c.password = ENV['GITHUB_APIPASS']
			c.perform

			members = Yajl::Parser.parse(c.body_str)			
			members.map { |member| member["login"] }.include?(username)
		end

	    def user_signed_in?
	    	return true if current_user
	    end
end
