class Resource < ActiveRecord::Base
  attr_accessible :name, :regex, :url
  validates :name, presence: true

  before_save do |resource|
  	resource.regex = Regexp.escape(resource.regex)
  end

  before_update do |resource|
  	resource.regex = Regexp.unescape(resource.regex)
  end
end
