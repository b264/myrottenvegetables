class String
  #get the last n characters of a string
  def last(n)
    self[-n, n]
  end
  def to_boolean
    return true if self=~ (/(true|t|yes|y|1)$/i)
    return false if self.blank? || self=~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new('Cannot convert to boolean')
  end
end
class NilClass
  #override one of Ruby's annoyances. nil IS empty.
  def empty?
    true
  end
end
class Fixnum
  def to_boolean
    return self.to_s.to_boolean
  end
end
