class VariableArray < Array
  def ==(other)
    if other.is_a?(Array)
      comp = self[1..(self.length - 1)]
      return comp.first == other.first
    else
      super
    end
  end
  def collect(&block)
    self.class.new.tap do |ret|
      self.each_with_index do |el, i|
        ret[i] = block.call(el)
      end
    end
  end
  alias_method :eql?, :==
end