class Hash
  def pathify_strings!
    self.each_pair do |k,v|
      if v.is_a?(Array) || v.is_a?(Hash)
        v.pathify_strings!
      elsif v.instance_of?(String)
        self[k] = PathString.new(URI.decode(v))
      end
    end
  end
end
class Array
  def pathify_strings!
    self.each_with_index do |v,k|
      if v.is_a?(Array) || v.is_a?(Hash)
        v.pathify_strings!
      elsif v.instance_of?(String)
        self[k] = PathString.new(URI.decode(v))
      end
    end
  end
end
class Hash
  def to_kief
    ret = HashDealer::Kief.new
    self.each_pair do |k,v|
      if v.instance_of?(Hash)
        ret[k] = v.to_kief
      elsif v.instance_of?(Array)
        ret[k] = v.collect{|n| n.instance_of?(Hash) ? n.to_kief : n}
      else
        ret[k] = v
      end
    end
    ret
  end
end
