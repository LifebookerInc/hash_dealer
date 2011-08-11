require 'active_support'

class PathString < String
  
  def == (other)
    # if either is a string that starts with a :, return true
    if self =~ /^:/ || other =~ /^:/
      return true
    elsif self =~ /\/:/ || other =~ /\/:/
      return self.paths_match?(self, other)
    else
      super
    end
  end
  
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
    val = val.is_a?(String) ? ActiveSupport::JSON.decode(val).sort : ActiveSupport::JSON.decode(ActiveSupport::JSON.encode(val)).sort
    val.pathify_strings!
    val
  end
  
  private
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