class Regexp
  def self.unescape(source)
    source = source.split('')
    escape_on = false
    unescaped_string = source.inject([]) {|r, char|
      if char == "\\" and escape_on == false
        escape_on = !escape_on
      else
        r << char
        escape_on = false
      end
      r
    }.join
  end
end