# encoding: utf-8
require 'carrierwave_config'

class LogfileUploader < CarrierWave::Uploader::Base  

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{model.class.to_s.underscore}/#{model.id}"
  end

  def self.drop_dir
    ENV['CW_UPLOADS_ROOT']+"/drop"
  end
end
