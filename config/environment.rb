# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Logmaster5000::Application.initialize!

# Load pow environment variables into development and test environments
if FileTest.exist?(".powenv")
	begin
		# read contents of .powenv
		powenv = File.open(".powenv", "rb")
		contents = powenv.read
		# parse content and retrieve variables from file
		lines = contents.gsub("export ", "").split(/\n\r?/).reject{|line| line.blank?}
		lines.each do |line|
			keyValue = line.split("=", 2)
			next unless keyValue.count == 2
			# set environment variable set in .powenv
			ENV[keyValue.first] = keyValue.last.gsub("'",'').gsub('"','')
		end
		# close file pointer
		powenv.close
		rescue => e
	end
end if Rails.env.development? || Rails.env.test?