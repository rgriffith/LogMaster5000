class SessionsController < ApplicationController
	def new
		redirect_to '/auth/github'
	end

	def create
		auth = request.env["omniauth.auth"]

		if auth[:uid]
			user = User.where(:provider => auth[:provider], 
			            :uid => auth[:uid]).first || User.create_with_omniauth(auth)
			session[:user_id] = user.id
			redirect_to logs_path
		else			
    		redirect_to root_url
    	end
  	end

  	def failure
		redirect_to root_url
	end

	def destroy
		reset_session
		redirect_to root_url
	end
end
