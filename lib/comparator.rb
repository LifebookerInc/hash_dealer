require 'active_support/core_ext'

class Comparator
  
  def self.normalize_value(val)
    return val if val.is_a?(TimeDateMatcher)
    val = ActiveSupport::JSON.decode(val) if val.is_a?(String)
    val = val.stringify_keys if val.is_a?(Hash)
    val = val.collect{|v| v.is_a?(Hash) || n.is_a?(Array) ? self.normalize_value(v) : v} if val.is_a?(Array)
    val
  end
  
  def self.diff(obj1, obj2)
    return {} if obj1 == obj2
    return self.array_diff(obj1, obj2) if obj1.is_a?(Array) && obj2.is_a?(Array)
    return self.hash_diff(obj1, obj2) if obj1.is_a?(Hash) && obj2.is_a?(Hash)
    return [obj1, obj2]
  end
  
  def self.array_diff(obj1, obj2)
    {}.tap do |ret|
      obj1.each_index do |k|
        ret[k] = self.diff(obj1[k], obj2[k]) unless obj1[k] == obj2[k]
      end
    end
  end
  
  def self.hash_diff(obj1, obj2)
    obj1, obj2 = self.stringify_keys(obj1), self.stringify_keys(obj2)
    (obj1.keys + obj2.keys).uniq.inject({}) do |memo, key|
      unless obj1[key] == obj2[key]
        if obj1[key].kind_of?(Hash) && obj2[key].kind_of?(Hash)
          memo[key] = self.diff(obj1[key],obj2[key])
        elsif obj1[key].kind_of?(Array) && obj2[key].kind_of?(Array)
          memo[key] = [].tap do |arr|
            obj1[key].each_index do |i|
              arr << self.diff(obj1[key][i], obj2[key][i])
            end
          end
        else
          memo[key] = self.diff(obj1[key], obj2[key]) 
        end
      end
      memo
    end
  end
  
  def self.stringify_keys(hash)
    {}.tap do |ret|
      hash.keys.each do |k|
        ret[k.to_s] = hash[k].is_a?(Hash) ? self.stringify_keys(hash[k]) : hash[k]
      end
    end
  end
    
end