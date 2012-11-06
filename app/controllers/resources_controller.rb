class ResourcesController < ApplicationController
	before_filter :authenticate_user!

	def index
		@resource = Resource.new
		@resources = Resource.all

		respond_to do |format|
			format.html
			format.json { render :json => @resources }
	    end
	end

	def new
		@resource = Resource.new

		respond_to do |format|
			format.html
			format.js { render :layout => false }
	    end
	end

	def show
		@resource = Resource.find params[:id]
		if !@resource
			redirect_to resources_path, :notice => {:type=> 'error', :message=>'There was a problem locating your resource.'}
		end
	end

	def create
		if params[:resource]
			resource = Resource.create params[:resource]

			if resource.errors.any?
				redirect_to :back, :notice => {:type=> 'error', :message=>'There was a problem creating your new resource.', :issues => { :type => "error", :messages => resource.errors.full_messages } }
		    else
				redirect_to resources_path, :notice => {:type=> 'success', :message=>'Resource has been created successfully.'}
			end
		else
			redirect_to :back, :notice => {:type=> 'error', :message=>'There was a problem creating your new resource.'}
		end		
	end

	def edit
		@resource = Resource.find params[:id]

		respond_to do |format|
			format.html
			format.js { render :layout => false }
	    end
	end

	def update
		resource = Resource.find params[:id]

		if resource.update_attributes params[:resource]			
			redirect_to :back, :notice => {:type=> 'success', :message=>'Resource has been updated successfully.'}
		else
			if resource.errors.any?
				redirect_to :back, :notice => {:type=> 'error', :message=>'There was a problem updating your resource.', :issues => { :type => "error", :messages => resource.errors.full_messages } }
		    else
				redirect_to :back, :notice => {:type=> 'error', :message=>'There was an error updating resource.'}
			end			
		end
	end

	def destroy
		resource = Resource.find params[:id]
		resource.destroy
		redirect_to :back, :notice => {:type=> 'success', :message=>'Resource has been deleted.'}
	end
end
