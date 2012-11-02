# encoding: utf-8

module LogParser
	module Parser
		class Base
			attr_accessor :log

			def initialize			
				@log = LogParser::Parser::Base::Log.new
			end

			def parse
				# Grab the lines in the file.
				lines_size = @log.size

				# Make sure we have some data to parse.
				if (lines_size < 1) || (lines_size == 1 && @log.lines[0].strip.empty?)				
					@log.entries
				end

				# Determine how many threads we should use.
				threads = LogParser.calculate_threads(lines_size)

				# Break the lines into an array of chunks to iterate over to find
				# points where entries are found.
				chunk_size = calculate_chunk_size(lines_size, threads)
				points = calculate_parse_points(chunk_size, threads)

				# Parse through the chunks.
				case LogParser.config[:thread_lib]
					when "em_synchrony"
						EM.synchrony do
							EM::Synchrony::FiberIterator.new(points, threads).each do |point|
								index = points.index(point)
								if index < points.size-1
									chunk = @log.lines[point..points.at(index+1)-1]
								else
									chunk = @log.lines[point..lines_size]
								end

								parse_chunk(chunk)
							end

							EventMachine.stop
						end
					when "parallel"
						Parallel.each_with_index(points, :in_threads => threads) { |point, index|
							if index < points.size-1
								chunk = @log.lines[point..points.at(index+1)-1]
							else
								chunk = @log.lines[point..lines_size]
							end

							parse_chunk(chunk)
						}
					else
						parse_chunk(@log.lines)
				end

				@log.entries
			end

			class Log
				attr_accessor :lines, :entries, :regex

				def initialize
					@lines = []
					@entries = {}
					@regex = {
						:timestamp => //,
						:entry => //
					}
				end

				def lines
					@lines
				end

				def size
					@lines.size			
				end

				def to_hash
					{ :line_total => size, :type => self.class.name.gsub(/LogParser::Parser::/, ""), :entries => @entries.values }
				end
			end

			private

			def calculate_chunk_size(lines_size, threads)
				chunk_size = (lines_size / threads).ceil
				chunk_size
			end

			def calculate_parse_points(chunk_size, threads)
				points = [0]
				if chunk_size > threads
					for i in 1..threads
						starting_line = i * chunk_size

						# Check to see if we land on an entry.
						# Else, parse through in chunks until we find one.				
						if @log.lines[starting_line] =~ @log.regex[:timestamp]
							points.push(starting_line)
						else
							entry_line = detect_entry_line(starting_line)
							if entry_line != nil
								points.push(entry_line)
							end
						end
					end
				end
				points
			end

			def detect_entry_line(startPoint, chunk_size=5)
				current_line = startPoint
				endPoint = startPoint+chunk_size

				if endPoint < @log.size
					@log.lines[startPoint..endPoint].each do |line| 
						current_line += 1
						if line =~ @log.regex[:timestamp]
							return current_line
						end
					end

					# Didn't find a match yet, so call again with the next 5 lines.
					detect_entry_line(endPoint, endPoint+chunk_size)
				end
			end

			def parse_chunk(chunk)			
			end
		end
	end
end