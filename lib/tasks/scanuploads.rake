
#lib/tasks/scanuploads.rake
require 'rake'

namespace :scanuploads do

	def create_log_from_file(f)
		log = Log.new
		log.logfile = f
		log.entriesjson = f
		log.save!

		log.labels << Label.find_or_create_by_name(ENV['CW_DROPFILE_DEFAULT_LABEL'])

		return log.errors.empty?
	end

	task :add_dropped_logs => :environment do
		storage = ENV['CW_STORAGE']

		puts "Using storage type: " + storage

		case storage
			when "sftp"
				require 'net/sftp'
				Net::SFTP.start(LogfileUploader.sftp_host, LogfileUploader.sftp_user, LogfileUploader.sftp_options) do |sftp|					
					sftp.dir.foreach(LogfileUploader.drop_dir) do |entry|
						next if entry.name.start_with?(".")
						
						drop_file_path = LogfileUploader.drop_dir+"/"+entry.name

						File.open(entry.name, "w") do |f|
							f.puts sftp.download!(drop_file_path)

							if create_log_from_file(f)
								sftp.remove!(drop_file_path)
							end
						end						
					end
				end
			when "ftp"
				require 'net/ftp'
				Net::FTP.open(LogfileUploader.ftp_host, LogfileUploader.ftp_user, LogfileUploader.ftp_passwd, LogfileUploader.ftp_port) do |ftp|
					ftp.dir.foreach(LogfileUploader.drop_dir) do |entry|
						next if entry.start_with?(".")
						
						drop_file_path = LogfileUploader.drop_dir+"/"+entry

						File.open(entry, "w") do |f|
							f.puts ftp.getbinaryfile(drop_file_path)

							if create_log_from_file(f)
								ftp.delete(drop_file_path)
							end
						end
					end
				end
			else
				Dir.foreach(LogfileUploader.drop_dir) do |entry|
					next if entry.start_with?(".")
					
					drop_file_path = LogfileUploader.drop_dir+"/"+entry

					if create_log_from_file(File.open(drop_file_path))
						File.delete(drop_file_path)
					end
				end
		end
	end
end