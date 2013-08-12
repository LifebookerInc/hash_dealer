class HashDealer
  class Hash < ::Hash

    def initialize(optional_attributes = [])
      @optional_attributes = optional_attributes
    end

    def eql?(other)
      self_for_comparison = self.remove_optional_keys(self)
      other_for_comparison = self.remove_optional_keys(other)

      self_for_comparison.eql?(other_for_comparison)
    end

    def ==(other)
      return self.eql?(other)
    end

    def to_hash
      ret = ::Hash.new
      self.each_pair do |k,v|
        ret[k] = v
      end
      ret
    end

    protected

    def remove_optional_keys(hash)
      hash = hash.clone.to_hash
      @optional_attributes.each do |optional_attribute|
        hash.delete(optional_attribute)
      end
      hash
    end

  end
end