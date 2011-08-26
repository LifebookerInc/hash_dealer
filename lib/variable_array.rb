class VariableArray < Array
  def ==(other)
    if other.is_a?(Array)
      comp = self[1..(self.length - 1)]
      return true if comp.first == other.first
    else
      super
    end
  end
  alias_method :eql?, :==
end