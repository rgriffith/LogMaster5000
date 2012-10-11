class Label < ActiveRecord::Base
	attr_accessible :name  
	has_and_belongs_to_many :logs
	validates :name, presence: true
	acts_as_url :name, :sync_url => true

  	def to_param
		url
	end
end