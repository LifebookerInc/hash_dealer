class Object
  # allows us to call matcher blindly
  def matcher(opts = {})
    return self
  end
end

class TimeDateMatcher
  attr_reader :instance
  def initialize(instance)
    @instance = instance
  end
  def ==(other)
    self.instance.class == other.class
  end
  alias_method :eql?, :==
end

# including a module didn't work here - not sure why though
[Time, DateTime, Date].each do |klass|
  klass.class_eval <<-EOE, __FILE__, __LINE__ + 1
    def matcher(opts = {})
      TimeDateMatcher.new(self)
    end

    alias_method :old_eql?, :eql?
    alias_method :old_equals_equals, :==

    def ==(other)
      return other == self if other.is_a?(TimeDateMatcher)
      return old_equals_equals(other)
    end

    def eql?(other)
      return other.eql?(self) if other.is_a?(TimeDateMatcher)
      return old_eql?(other)
    end
    
  EOE
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
  def pathify_strings
    self.each_pair do |k,v|
      if v.is_a?(Array) || v.is_a?(Hash)
        self[k] = v.pathify_strings
      elsif v.instance_of?(String) || v.is_a?(Numeric)
        self[k] = PathString.new(URI.decode(v.to_s))
      end
    end
    self
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
  def pathify_strings
    if self.first == ":matcher"
      val = VariableArray.new(self)
    else
      val = self
    end
    val.each_with_index do |v,k|
      if v.is_a?(Array)  || v.is_a?(Hash)
        val[k] = v.pathify_strings
      elsif v.instance_of?(String) || v.is_a?(Numeric)
        val[k] = PathString.new(URI.decode(v.to_s))
      end
    end
    val
  end
  # call matcher on all of the elements
  def matcher(opts = {})
    self.unshift(":matcher")
    VariableArray.new(self.collect(&:matcher))
  end
  # we want this to apply to both :eql? and ==
  alias_method :eql?, :==
  # we want this to add decorator behavior to ==, proxying to VariableArray if possible
  define_method "==_with_variable_array" do |other|
    return other == self if other.is_a?(VariableArray)
    self.send("==_without_variable_array",other)
  end
  # Equivalent to:
  # alias_method_chain "==", "variable_array"
  alias_method "==_without_variable_array", :==
  alias_method :==, "==_with_variable_array"
end
