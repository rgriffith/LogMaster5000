class LogsController < ApplicationController
	before_filter :authenticate_user!

	def index
		@log = Log.new
		@logs = Log.all
	end

	def new
		@log = Log.new

		respond_to do |format|
			format.html
			format.js { render :layout => false }
	    end
	end

	def create		
		if params[:log]
			warnings = []

			log = Log.new
			log.logfile = params[:log][:logfile]			
			log.save!

			if params[:hiddenTagList]
				log_labels = params[:hiddenTagList].split(',')
				log_labels.each do |label|
					new_label = Label.find_or_create_by_name(label)
					if new_label.errors.any?
						warnings.push(new_label.errors.full_messages)
					else
						log.labels << new_label
					end
				end
			end
			
			redirect_to :back, :notice => {:type=> 'success', :message=>'Log has been created successfully.', :issues => { :type => "warning", :messages => warnings.flatten} }
		else
			redirect_to :back, :notice => {:type=> 'error', :message=>'Please choose a log file for upload.'}
		end		
	end

	def show
		require 'logparser'
		@log = Log.find params[:id]

		parser_opts = {}
		if params[:clear_cache] == "true"
			parser_opts = {
				:clear_cache => true
			}
			flash.now[:notice] = {:type => "success", :message => "Cache updated successfully."}
		end

		@entries = LogParser.fiber_aware_parse(@log.logfile.current_path, parser_opts)

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

		respond_to do |format|
			format.html
			format.js { render :layout => false }
	    end
	end

	def update
		log = Log.find params[:id]		
		success = true
		warnings = []

		# Update log's labels.
		log.labels.clear
		if params[:hiddenTagList]
			log_labels = params[:hiddenTagList].split(',')
			log_labels.each do |label|
				new_label = Label.find_or_create_by_name(label)
				if new_label.errors.any?
					warnings.push new_label.errors.full_messages
				else
					log.labels << new_label
				end
			end
		end

		if params[:log]			
			if !log.update_attributes params[:log]
				success = false
			end
		end

		if success			
			redirect_to :back, :notice => {:type=> 'success', :message=>'Log has been updated successfully.', :issues => { :type => "warning", :messages => warnings.flatten} }
		else
			redirect_to :back, :notice => {:type=> 'error', :message=>'There was an error updating log.', :issues => { :type => "warning", :messages => warnings.flatten} }
		end	
	end

	def destroy
		Log.destroy params[:id]
		redirect_to :back, :notice => {:type=> 'success', :message=>'Log has been deleted.'}
	end

	def download
		require 'mime/types'
		@log = Log.find params[:id]
		send_file @log.logfile.current_path, :type => MIME::Types.type_for(@log.logfile.current_path), :filename => File.basename(@log.logfile.current_path)
	end
end
