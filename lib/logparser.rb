# encoding: utf-8

require "em-synchrony"
require "em-synchrony/fiber_iterator"
require "parallel"

module LogParser	

	class << self
		attr_accessor :config

		def configure(opts = {})
			defaults = {
				:max_threads => 40,
				:max_chunk_size => 2500,
				:registered_parsers => {
					:cascade => "LogParser::Parser::Cascade",
					:catalina => "LogParser::Parser::Catalina"
				},
				:thread_lib => "parallel"
			}
			
			@config = defaults.merge(opts)
		end

		def calculate_threads(lines_size)
			threads = (lines_size / @config[:max_chunk_size]).ceil
			if (threads > @config[:max_threads])
				threads = @config[:max_threads]
			elsif (threads < 1)
				threads = 1
			end
			threads
		end

		def parse_log(lines)
			p = detect_parser(lines[0..3])

			if p.nil?
				return nil
			else
				p.log.lines = lines
				p.parse
				return p.log
			end
		end

		private

		def detect_parser(lines)
			parser = nil
			@config[:registered_parsers].each_value do |p|
				p = eval(p).new				
				lines.each do |line|
					if line =~ p.log.regex[:timestamp]
						return p
					end
				end	
			end
			parser
		end		
	end

	module Parser
		autoload :Base, 'logparser/parser'
		autoload :Cascade, 'logparser/parser/cascade'
		autoload :Catalina, 'logparser/parser/catalina'
	end
end

LogParser.configure