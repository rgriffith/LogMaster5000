class LogsController < ApplicationController
	def index
		@log = Log.new
		@logs = Log.all
	end

	def create
		if params[:log]
			log = Log.new
			log.logfile = params[:log][:logfile]
			log.save!
			redirect_to :back, :notice => {:type=> 'success', :message=>'Log has been created successfully.'}
		else
			redirect_to :back, :notice => {:type=> 'error', :message=>'Please choose a log file for upload.'}
		end		
	end

	def show
		require 'logparser'
		@log = Log.find params[:id]

		@entries = LogParser.fiber_aware_parse(@log.logfile.current_path)

		@line_total = @entries[:line_total]
		@entry_count = @entries[:entries].size

		if @line_total == 0
			redirect_to :back, :notice => {:type => "error", :message => "It looks like the file that was specified was empty. Please choose a file below or upload a new one."}
		elsif @line_total == -1
			redirect_to :back, :notice => {:type => "error", :message => "It looks like the file that was specified does not exist. Please choose a file below or upload a new one."}
		end

		@output = { 			
			:aaData => @entries[:entries]
		}

		respond_to do |format|
			format.html {
				@output = @output.to_json
			}
			format.json { render :json => @output }
	    end
	end

	def edit
		@log = Log.find params[:id]
	end

	def update
		log = Log.find params[:id]

		if log.update_attributes params[:log]
			redirect_to logs_path, :notice => {:type=> 'success', :message=>'Log has been updated successfully.'}
		else
			redirect_to :back, :notice => {:type=> 'error', :message=>'There was an error updating log.'}
		end
	end

	def destroy
		Log.destroy params[:id]
		redirect_to :back, :notice => {:type=> 'success', :message=>'Log has been deleted.'}
	end
end
