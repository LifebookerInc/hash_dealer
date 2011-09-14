require "active_support"

class PathString < String
  
  def == (other)
    # if either is a string that starts with a :, return true
   if self =~ /^:/ || (other.is_a?(Numeric) && self =~ /^:\d+$/) || other =~ /^:/
      return true
    elsif self =~ /\/:/ || other =~ /\/:/
      return self.class.paths_match?(self, other)
    else
      super
    end
  end
  alias_method :eql?, :==
  
  def self.paths_match?(a, b)
    self.get_zipped_array(a, b).each do |kp, ep|
      # only known path can have things prefixed with colons which is protected
      if kp.nil? || ep.nil?
        return false
      elsif String.new(kp) != String.new(ep) && !kp.start_with?(":") && !ep.start_with?(":")
        return false
      end
    end
    return true
  end
  
  def self.as_sorted_json(val)
    val = self.sort_json(val)
    val = val.pathify_strings
    val
  end
  
  # helper method to be called recursively
  def self.sort_json(val)
    return val if val.is_a?(TimeDateMatcher)
    val = ActiveSupport::JSON.decode(val) if val.is_a?(String)
    val = self.stringify_keys(val).sort if val.is_a?(Hash)
    val = val.collect{|v| v.collect{|n| n.is_a?(Hash) ? self.sort_json(n) : n}} if val.is_a?(Array)
    val.sort
  end
  
  # 
  # 
  def self.extract_params(known_path, entered_path)
    params = {}.with_indifferent_access
    
    self.get_zipped_array(known_path, entered_path).each do |kp, ep|
      if kp.nil? || ep.nil?
        raise Exception.new("Cannot extract params for routes that don't match")
      end
      if kp.start_with?(":")
        if params[kp[1..-1]]
          raise Exception.new("Cannot define a route containing two parameters with the same name")
        else
          params[kp[1..-1]] = ep
        end
      end
    end
    return params
  end
  
  def self.diff(a,b)
    a, b = self.as_sorted_json(a), self.as_sorted_json(b)
    diff = []
    a.each_index do |i|
      unless a[i] == b[i]
        diff << {:expected => a[i], :got => b[i]}
      end
    end
    diff
  end
  
  
  private
  
  def self.stringify_keys(hash)
    new_hash = hash.class.new
    hash.each_pair do |k,v|
      new_hash[k.to_s] = case v
        when Hash
          self.stringify_keys(v)
        when Array
          self.stringify_array_keys(v)
        else
         v 
      end
    end
    new_hash
  end
  
  # 
  def self.stringify_array_keys(array)
    array.collect{|v|
      case v
        when Hash
          self.stringify_keys(v)
        when Array
          self.stringify_array_keys(v)
        else
          v
      end
    }
  end
  
  def self.get_zipped_array(known_path, entered_path)
    # make these strings
    known_path, entered_path = known_path.to_s, entered_path.to_s
    # Remove the any beginning or trailing slashes from both paths if they exist
    known_path = known_path[1..-1] if known_path.start_with?("/")
    known_path = known_path[0..-2] if known_path.end_with?("/")
    entered_path = entered_path[1..-1] if entered_path.start_with?("/")
    entered_path = entered_path[0..-2] if entered_path.end_with?("/")
    known_path = known_path.split("/")
    entered_path = entered_path.split("/")
    if known_path.length < entered_path.length
      (entered_path.length - known_path.length).times do
        known_path << nil
      end
    end
    return known_path.zip(entered_path)
  end
  
end
