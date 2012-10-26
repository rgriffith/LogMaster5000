#app/uploaders/carrierwave_config.rb
CarrierWave.configure do |config|
  case ENV['CW_STORAGE'] 
    when "sftp"
      config.storage = :sftp
      config.sftp_host = ENV['CW_SFTP_HOST']
      config.sftp_user = ENV['CW_SFTP_USER']
      config.sftp_folder = ENV['CW_UPLOADS_ROOT']
      config.sftp_url = ENV['CW_SFTP_URL']
      config.sftp_options = {
        :password => ENV['CW_SFTP_PASSWORD'],
        :port     => ENV['CW_SFTP_PORT'] || 22
      }      
    when "ftp"
      config.storage = :ftp
      config.ftp_host = ENV['CW_FTP_HOST']
      config.ftp_port = ENV['CW_FTP_PORT'] || 21
      config.ftp_user = ENV['CW_FTP_USER']
      config.ftp_folder = ENV['CW_UPLOADS_ROOT']
      config.ftp_url = ENV['CW_FTP_URL']  
    else
        config.storage = :file
  end
end