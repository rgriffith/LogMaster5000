class SessionsController < ApplicationController	
	def new
		# Is the user already logged in?		
		if session[:user_id] && :user_signed_in?
			redirect_to logs_path
		end

		if params[:username]
			if params[:username] == ''
				notice = {:type => 'error', :message => 'Please enter your Username in the field provided.'}
			elsif !organization_member?(params[:username])
				notice = {:type => 'error', :message => 'Sorry, but you do not have access to this application.'}
			end

			if notice
				flash.now[:notice] = notice
			else
				redirect_to '/auth/github'
			end
		end
	end

	def create
		auth = request.env["omniauth.auth"]

		logger.debug(auth)

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
		render :new
	end

	def destroy
		if session[:user_id]
			User.delete session[:user_id]
			reset_session
		end
		redirect_to login_path, :notice => {:type => 'success', :message => 'You have been logged out successfully. Don\'t forget to revoke access to this application through the <a href="https://github.com/settings/applications">Github Applications</a> page.'}
	end
end
