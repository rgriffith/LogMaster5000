require 'zlib'
require 'digest/md5'
require 'base64'
require "cgi"

class String
	def str_to_crc32
		Zlib.crc32(self)
	end

	def str_to_md5
		Digest::MD5.hexdigest(self)
	end

	def base64_encode
		Base64.strict_encode64(self)
	end

	def base64_decode
		Base64.decode64(self)
	end

	def json_escape
		result = self.to_s.gsub('/', '\/')
		self.html_safe? ? result.html_safe : result
	end

	def htmlentities
		CGI::escapeHTML(self)
	end
end