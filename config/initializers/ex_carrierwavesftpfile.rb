require 'carrierwave/storage/ftp'


class CarrierWave::Storage::SFTP::File
	def mtime
		stat.mtime
	end

	def read
		data = nil
		connection do |sftp|
        	sftp.file.open(full_path) do |file|
				data = file.read
			end
      	end
      	data
	end

	def readlines
		read.split("\n")
	end

	def stat
		stat = nil
		connection do |sftp|
			stat = sftp.stat!(full_path)
		end
		stat
	end
end