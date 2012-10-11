require 'carrierwave/orm/activerecord'
require 'fileutils'

class Log < ActiveRecord::Base
  attr_accessible :logfile
  validates :logfile, presence: true
  mount_uploader :logfile, LogfileUploader
  before_destroy :remove_uploader_folder
  has_and_belongs_to_many :labels

  def remove_uploader_folder
  	FileUtils.rm_rf(File.dirname(logfile.current_path))
  end
end
