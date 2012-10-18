class LabelsController < ApplicationController
	before_filter :authenticate_user!

	def index
		@label = Label.new
		@labels = Label.all

		respond_to do |format|
			format.html
			format.json { render :json => @labels }
	    end
	end

	def new
		@label = Label.new

		respond_to do |format|
			format.html
			format.js { render :layout => false }
	    end
	end

	def get_names
		@labels = Label.all

		respond_to do |format|
			format.json { render :json => { :tags => @labels.collect{|label| {:tag => label.name}} } }
	    end
	end

	def show
		@label = Label.find_by_url params[:id]
		if @label
			@logs = @label.logs
		else
			redirect_to labels_path, :notice => {:type=> 'error', :message=>'There was a problem locating your label.'}
		end
	end

	def create
		if params[:label]
			label = Label.create params[:label]

			if label.errors.any?
				redirect_to :back, :notice => {:type=> 'error', :message=>'There was a problem creating your new label.', :issues => { :type => "error", :messages => label.errors.full_messages } }
		    else
				redirect_to labels_path, :notice => {:type=> 'success', :message=>'Label has been created successfully.'}
			end
		else
			redirect_to :back, :notice => {:type=> 'error', :message=>'There was a problem creating your new label.'}
		end		
	end

	def edit
		@label = Label.find_by_url params[:id]

		respond_to do |format|
			format.html
			format.js { render :layout => false }
	    end
	end

	def update
		label = Label.find_by_url params[:id]

		if label.update_attributes params[:label]			
			redirect_to :back, :notice => {:type=> 'success', :message=>'Label has been updated successfully.'}
		else
			if label.errors.any?
				redirect_to :back, :notice => {:type=> 'error', :message=>'There was a problem updating your label.', :issues => { :type => "error", :messages => label.errors.full_messages } }
		    else
				redirect_to :back, :notice => {:type=> 'error', :message=>'There was an error updating label.'}
			end			
		end
	end

	def destroy
		label = Label.find_by_url params[:id]
		label.destroy
		redirect_to :back, :notice => {:type=> 'success', :message=>'Label has been deleted.'}
	end
end
