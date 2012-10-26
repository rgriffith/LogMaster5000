CarrierWave.configure do |config|
	if Rails.env.test? or Rails.env.cucumber?
		config.storage = :file
		config.enable_processing = false
	elsif Rails.env.development?
		config.storage = :file		
	else
		config.storage = :sftp
		config.sftp_host = ENV['CARRIERWAVE_SFTP_HOST']
		config.sftp_user = ENV['CARRIERWAVE_SFTP_USER']
		config.sftp_folder = ENV['CARRIERWAVE_SFTP_FOLDER']
		config.sftp_url = ENV['CARRIERWAVE_SFTP_URL']
		config.sftp_options = {
			:password => ENV['CARRIERWAVE_SFTP_PASSWORD'],
			:port     => 22
		}
	end
end