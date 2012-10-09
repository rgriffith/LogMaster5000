#require "logging"
require "fileutils"

module LogParser
=begin
	@logger = Logging.logger('debug')
	@logger.add_appenders(
	    Logging.appenders.file('log/development.log')
	)
	@logger.level = :debug
=end
	@@defaults = {
		:threads => 40,
		:thread_lib => "em_synchrony",
		:cache_dir => Rails.root.join('public','logs','cache'),
		:use_cache => true
	}

	@@entry_regex = {
		:log => {
			:timestamp => /^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2},\d{3,}\b/,
			:entry => /^(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2},\d{3,})\s+(\w{1,})\s+\[([\w\$\[\]\/-]*)\]\s+([^\n]*)/
		}
	}
	
	@lines = Array.new
	@entries = {}

	class << self
		def fiber_aware_parse(file_path, opts = {})
			if opts[:threads]
				threads = opts[:threads]
			else
				threads = @@defaults[:threads]
			end

			if opts[:thread_lib]
				thread_lib = opts[:threads]
			else
				thread_lib = @@defaults[:thread_lib]
			end

			if opts[:clear_cache].nil? == false && opts[:clear_cache]
				clear_cache = true
			else
				clear_cache = false
			end

			@entries = {}
			points = [0]
			cache_file = file_path + ".cache"

			# Make sure we have a file.
			if (File.size?(file_path) == nil)
				return { :line_total => -1, :entries => [] }
			end

			# Check for a valid cache file unless overwrite is supplied.		
			if clear_cache == false && cache_exists?(cache_file)
				return get_cache(cache_file) unless nil
			end

			# Grab the lines in the file.
			File.open(file_path, 'r') do |f|
				@lines = f.readlines.to_a
				f.close()
			end

			# Make sure we have some data to parse.
			if (@lines.size < 1) || (@lines.size == 1 && @lines[0].strip.empty?)
				return { :line_total => 0, :entries => [] }
			end

			# Break the lines into an array of chunks to iterate over to find
			# points where entries are found.
			chunk_size = (@lines.size / threads).ceil	

			for i in 1..threads
				starting_line = i * chunk_size

				# Check to see if we land on an entry.
				# Else, parse through in chunks until we find one.				
				if @lines[starting_line] =~ @@entry_regex[:log][:entry]
					points.push(starting_line)
				else
					entry_line = find_entry_line(starting_line)
					if entry_line != nil
						points.push(entry_line)
					end
				end
			end

			# Parse through the chunks.
			case thread_lib
				when "em_synchrony"
					require "em-synchrony"
					require "em-synchrony/fiber_iterator"

					EM.synchrony do
						EM::Synchrony::FiberIterator.new(points, threads).each do |point|
							index = points.index(point)
							if index < points.size-1
								chunk = @lines[point..points.at(index+1)-1]
							else
								chunk = @lines[point..@lines.size()]
							end

							parse_chunk(chunk)
						end

						EventMachine.stop
					end
				when "parallel"
					require "parallel"

					Parallel.each_with_index(points, :in_threads => threads) { |point, index|
						if index < points.size-1
							chunk = @lines[point..points.at(index+1)-1]
						else
							chunk = @lines[point..@lines.size()]
						end

						parse_chunk(chunk)
					}
				else
					parse_chunk(@lines)
			end

			return_hash = { :line_total => @lines.size, :entries => @entries.values }

			# Save to cache
			save_to_cache(cache_file, return_hash)

			return return_hash
		end

		def find_entry_line(startPoint, chunk_size=5)
			current_line = startPoint
			endPoint = startPoint+chunk_size

			if endPoint < @lines.size
				@lines[startPoint..endPoint].each do |line| 
					current_line += 1
					if line =~ @@entry_regex[:log][:entry]
						return current_line
					end
				end

				# Didn't find a match yet, so call again with the next 5 lines.
				find_entry_line(endPoint, endPoint+chunk_size)
			end
		end

		def parse_chunk(chunk)						
			tempEntry = {}
			linesToSkip = 0
			currentLineText = ""

			chunk.each_with_index do |line, index| 
				# Skip the line if it's empty.
				next if line.strip.empty?

				# Are we in a stack trace that was recorded already? Skip if true
				if linesToSkip > 0
					linesToSkip -= 1
					next
				end		

				# Are we on an entry line, or a stack trace?
				timestamp = line.match(@@entry_regex[:log][:timestamp])

				# If there is no match, we're within a stack trace.
				if timestamp.nil?
					# Make sure we're not already writing a stack trace in another process...
					if tempEntry.empty? == false && tempEntry[:traceWriteLock]
						tempEntry[:trace] += line
						tempEntry[:lineCount] += 1
					end
				else
					# Are we reading the same entry again?
					currentLineText = line.slice(timestamp[0].length, line.length)
					if tempEntry.empty? == false && tempEntry[:entrycontent] == currentLineText
						tempEntry[:timestamp] << timestamp[0]
						tempEntry[:hits] += 1			
						next
					end

					# We'll need to match the entire line for additional comparison, or recording.
					match = line.match(@@entry_regex[:log][:entry])

					timestamp = $1
					level = $2
					classObj = $3

					if $4.nil?
						message = ""
					else
						message = $4.gsub(/\n|\r/,'')
					end

					# Call custom str_to_{hash} method
					checksum = message.str_to_crc32
					#checksum = message.str_to_md5

					# Do we have an existing entry?					
					if @entries.has_key?(checksum)
						if (tempEntry = @entries[checksum]) && (tempEntry != nil)
							# Set the trace write lock to false. Used for other processes that 
							# may have encountered a match (avoids appending duplicate traces).
							if tempEntry[:traceWriteLock] == true
								tempEntry[:traceWriteLock] = false
							end

							tempEntry[:timestamp] << timestamp
							tempEntry[:hits] += 1

							if tempEntry[:lineCount] > 1
								linesToSkip = tempEntry[:lineCount]-1
							end
						end
					else
						# Record the entry.	
						tempEntry = {
							:entrycontent => currentLineText,
							:checksum => checksum,
							:timestamp => [timestamp],
							:level => level,
							:class => classObj,
							:message => message,
							:shortmessage => message.truncate(150),
							:trace => "",
							:lineCount => 1,
							:hits => 1,
							:traceWriteLock => true
						}

						@entries[checksum] = tempEntry
					end
				end
			end
		end

		def cache_exists?(file_path)
			return File.exists?(file_path)
		end

		def get_cache(file_path)
			if cache_exists?(file_path)
				File.open(file_path, "rb") { |f| 
					return Marshal.load(f) 
				}
			else
				return nil
			end
		end

		def save_to_cache(file_path, entries)
			cache_dirname = File.dirname(file_path)
			if File.exists?(cache_dirname) == false
				FileUtils.mkdir(cache_dirname)
			end

			File.open(file_path, "wb") { |f| 
				Marshal.dump(entries, f)
			}
		end
	end
end