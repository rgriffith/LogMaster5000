# encoding: utf-8

module LogParser
	module Parser
		class Cascade < Base
			attr_accessor :log

			def initialize			
				@log = LogParser::Parser::Cascade::Log.new
			end

			class Log < Base::Log
				attr_accessor :lines, :entries, :regex

				def initialize
					@lines = []
					@entries = {}
					@regex = {
						:timestamp => /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3,}/,
						:entry => /^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3,}) (\w{1,})\s+\[([^\[\]]+||\[\/\])\] ([^\r]+)/
					}
				end
			end

			private

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
					timestamp = line.match(@log.regex[:timestamp])

					# If there is no match, we're within a stack trace.
					if timestamp.nil?
						# Make sure we're not already writing a stack trace in another process...
						if tempEntry.empty? == false && tempEntry[:traceWriteLock]
							tempEntry[:trace] += line.htmlentities
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
						match = line.match(@log.regex[:entry])

						timestamp = $1
						level = $2
						classObj = $3

						if $4.nil?
							message = ""
						else
							message = $4.gsub(/\n|\r/,'').htmlentities
						end

						# Call custom str_to_{hash} method
						checksum = message.str_to_crc32
						#checksum = message.str_to_md5

						# Do we have an existing entry?					
						if @log.entries.has_key?(checksum)
							if (tempEntry = @log.entries[checksum]) && (tempEntry != nil)
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
								:entrycontent => currentLineText.htmlentities,
								:checksum => checksum,
								:timestamp => [timestamp],
								:level => level,
								:class => classObj,
								:message => message,
								:shortmessage => message.truncate(150),
								:trace => level + " [" + classObj + "] " + message + "\r",
								:lineCount => 1,
								:hits => 1,
								:traceWriteLock => true
							}

							@log.entries[checksum] = tempEntry
						end
					end
				end
			end
		end
	end
end