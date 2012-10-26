require 'carrierwave/orm/activerecord'
require 'fileutils'

class Log < ActiveRecord::Base
  attr_accessible :logfile, :entriesjson
  validates :logfile, presence: true
  mount_uploader :logfile, LogfileUploader
  mount_uploader :entriesjson, EntriesJsonUploader
  has_and_belongs_to_many :labels
end