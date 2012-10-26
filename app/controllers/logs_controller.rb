class LogsController < ApplicationController
	before_filter :authenticate_user!

	def index
		@log = Log.new
		@logs = Log.all		
	end

	def new
		@log = Log.new
	end

	def create
		if params[:log]
			log = Log.new
			log.logfile = params[:log][:logfile]
			log.entriesjson = params[:log][:logfile]
			log.save!

			log_labels = eval(params[:labels])
			if log_labels
				log_labels.each do |label|
					log.labels << Label.find_or_create_by_name(label)
				end
			end
			
			redirect_to :back, :notice => {:type=> 'success', :message=>'Log has been created successfully.'}
		else
			redirect_to :back, :notice => {:type=> 'error', :message=>'Please choose a log file for upload.'}
		end		
	end

	def show
		require 'logparser'
		require 'yajl'

		@log = Log.find params[:id]

		@entries = {
			:data => @log.entriesjson.read
		}
		@entries[:json_hash] = Yajl::Parser.new.parse(@entries[:data])

		if @entries[:json_hash]["line_total"] == 0
			redirect_to :back, :notice => {:type => "error", :message => "It looks like the file that was specified was empty. Please choose a file below or upload a new one."}
		elsif @log.logfile.size.nil?
			redirect_to :back, :notice => {:type => "error", :message => "It looks like the file that was specified does not exist. Please choose a file below or upload a new one."}
		end

		respond_to do |format|
			format.html
			format.json { render :json => @entries[:data] }
	    end
	end

	def edit
		@log = Log.find params[:id]
	end

	def update
		log = Log.find params[:id]
		log_labels = eval(params[:labels])

		# Update log's labels.
		log.labels.clear
		if log_labels
			log_labels.each do |label|
				log.labels << Label.find_or_create_by_name(label)
			end
		end

		if params[:log]
<<<<<<< Updated upstream
			if !log.update_attributes params[:log]
				redirect_to :back, :notice => {:type=> 'error', :message=>'There was an error updating log.'}
=======
			log.logfile = params[:log][:logfile]
			log.entriesjson = params[:log][:logfile]

			if !log.save!
				success = false
>>>>>>> Stashed changes
			end
		end

		redirect_to logs_path, :notice => {:type=> 'success', :message=>'Log has been updated successfully.'}
	end

	def destroy
		Log.destroy params[:id]
		redirect_to :back, :notice => {:type=> 'success', :message=>'Log has been deleted.'}
	end

	def download
		require 'mime/types'
		@log = Log.find params[:id]
		filename = @log.logfile.file.filename
		send_data @log.logfile.read, :type => MIME::Types.type_for(filename), :filename => File.basename(filename)
	end
end
