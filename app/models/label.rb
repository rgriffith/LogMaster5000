class Label < ActiveRecord::Base
	attr_accessible :name  
	has_and_belongs_to_many :logs

	validates :name, :presence => true, :exclusion => { :in => %w(new get_names), :message => "<strong>%{value}</strong> is reserved." }

	acts_as_url :name, :sync_url => true

  	def to_param
		url
	end
end