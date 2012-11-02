# encoding: utf-8

module LogParser
	module Parser
		class Catalina < Base
			attr_accessor :log

			def initialize			
				@log = LogParser::Parser::Catalina::Log.new
			end

			class Log < Base::Log
				attr_accessor :lines, :entries, :regex

				def initialize
					@lines = []
					@entries = {}
					@regex = {
						:timestamp => /^(\w{3} \d{1,2}, \d{4} \d{1,2}:\d{2}:\d{2} [A|P]M)/,
						:entry => /^(\w{3} \d{1,2}, \d{4} \d{1,2}:\d{2}:\d{2} [A|P]M) ([^\s]+) ([^\r]+)/,
						:message => /([^:\s]+): ([^\r]+)/
					}
				end
			end

			private

			def parse_chunk(chunk)
				tempEntry = {}
				linesToSkip = 0
				currentLineText = ""

				chunk.each_with_index do |line, index| 
					# Are we on an entry line, or a stack trace?
					timestamp = line.match(@log.regex[:timestamp])

					# Skip the line if it's empty.
					next if line.strip.empty? or timestamp.nil?

					# We'll need to match the entire line for additional comparison, or recording.
					match = line.match(@log.regex[:entry])

					timestamp = $1
					classObj = $2
					method = $3

					match = chunk[index+1].match(@log.regex[:message])

					level = $1
					message = $2

					# Call custom str_to_{hash} method
					currentLineText = level+" "+"["+classObj+"."+method+"] "+message
					checksum = currentLineText.str_to_crc32
					#checksum = currentLineText.str_to_md5

					# Record the entry.	
					tempEntry = {
						:entrycontent => currentLineText,
						:checksum => checksum,
						:timestamp => [timestamp],
						:level => level,
						:class => classObj,
						:message => message,
						:shortmessage => message,
						:trace => timestamp + " " + classObj + " " + method + "\r" + level + ": " + message,
						:lineCount => 2,
						:hits => 1,
						:traceWriteLock => true
					}

					@log.entries[checksum] = tempEntry
				end
			end
		end
	end
end