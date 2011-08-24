class Object
  # allows us to call matcher blindly
  def matcher(opts = {})
    return self
  end
end

class Numeric
  def matcher(opts={})
    PathString.new(":#{self}")
  end
  def ==(other)
    return true if other.is_a?(PathString) && other =~ /^:/
    super
  end
  alias_method :eql?, :==
end

# The only really important matcher
class String
  def matcher(opts = {})
    # if we have a leading : or a /:xyz - a matcher is already defined
    self =~ /(^:|\/:)/ ? self : ":#{self}"
  end
end

class Hash
  def pathify_strings!
    self.each_pair do |k,v|
      if v.is_a?(Array) || v.is_a?(Hash)
        v.pathify_strings!
      elsif v.instance_of?(String) || v.is_a?(Numeric)
        self[k] = PathString.new(URI.decode(v.to_s))
      end
    end
  end
  # recursively get a matcher for each value
  def matcher(opts = {})
    opts[:only] ||= self.keys.collect(&:to_sym)
    opts[:only] = opts[:only].collect(&:to_sym)
    opts[:only] -= (opts[:except] || []).collect(&:to_sym)
    
    ret = self.class.new
    self.each_pair do |k,v|
      if opts[:only].include?(k.to_sym)
        ret[k] = v.matcher(opts[k.to_sym] || {})
      else
        ret[k] = v
      end
    end
    ret
  end
end
class Array
  def pathify_strings!
    self.each_with_index do |v,k|
      if v.is_a?(Array) || v.is_a?(Hash)
        v.pathify_strings!
      elsif v.instance_of?(String) || v.is_a?(Numeric)
        self[k] = PathString.new(URI.decode(v.to_s))
      end
    end
  end
  # call matcher on all of the elements
  def matcher(opts = {})
    self.collect(&:matcher)
  end
end