require 'yajl'

class LogsController < ApplicationController
	before_filter :authenticate_user!

	def index
		@log = Log.new
		@logs = Log.all		
	end

	def create		
		if params[:log]
			warnings = []

			log = Log.new
			log.logfile = params[:log][:logfile]	
			log.entriesjson = params[:log][:logfile]		
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

	def edit
		@log = Log.find params[:id]
	end

	def new
		@log = Log.new
	end

	def resources
		@log = Log.find params[:id]
		@entries = Yajl::Parser.new.parse(@log.entriesjson.read)

		@resource_matches = _find_resource_matches(@entries["entries"])

		respond_to do |format|
			format.html
			format.js
			format.json { render :json => @matches }
	  end
	end

	def show
		@log = Log.find params[:id]

		@entries = {
			:data => @log.entriesjson.read
		}
		@entries[:json_hash] = Yajl::Parser.new.parse(@entries[:data])

		if @entries[:json_hash]["type"].nil?
			@entries[:json_hash]["type"] = ""
		end

		if @entries[:json_hash]["line_total"] == 0
			redirect_to :back, :notice => {:type => "error", :message => "It looks like the file that was specified was empty. Please choose a file below or upload a new one."}
		elsif @log.logfile.size.nil?
			redirect_to :back, :notice => {:type => "error", :message => "It looks like the file that was specified does not exist. Please choose a file below or upload a new one."}
		end

		@resource_matches = _find_resource_matches(@entries[:json_hash]["entries"])

		respond_to do |format|
			format.html
			format.json { render :json => @entries[:data] }
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
			log.logfile = params[:log][:logfile]
			log.entriesjson = params[:log][:logfile]

			if !log.save!
				success = false
			end
		end

		if success			
			redirect_to :back, :notice => {:type=> 'success', :message=>'Log has been updated successfully.', :issues => { :type => "warning", :messages => warnings.flatten} }
		else
			redirect_to :back, :notice => {:type=> 'error', :message=>'There was an error updating log.', :issues => { :type => "warning", :messages => warnings.flatten} }
		end	
	end

	def _find_resource_matches(log_entries)
		resource_matches = {}

		regexes = Resource.all.collect{|resource| {
			:resource => resource,
			:regex => Regexp.new(resource.regex)
		}}

		## Loop over each entry to see if we have a resource for it.
		log_entries.each do |entry|
			regexes.each do |regex|
					next unless regex[:regex] =~ entry["entrycontent"]
					if resource_matches.has_key?(regex[:resource].id)
						resource_matches[regex[:resource].id][:hits] += 1
					else
						resource_matches[regex[:resource].id] = {:resource => regex[:resource], :hits => entry["hits"]}
					end
			end
		end
		resource_matches
	end
end
