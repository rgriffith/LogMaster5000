# encoding: utf-8
require 'carrierwave_config'

class EntriesJsonUploader < CarrierWave::Uploader::Base

  process :parse_log    

  def parse_log
    require 'logparser'
    f = File.open(path, 'r')
    lines = f.readlines
    json = LogParser.parse_log(lines,{:thread_lib=>"parallel"}).to_json
    f.reopen(path, "w")
    f.write json.force_encoding("UTF-8")
    f.close()
  end

  def full_filename (for_file = model.logfile.file) 
    "entries.json"
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

end
