require 'colorize'

require File.expand_path('../path_string', __FILE__)
require File.expand_path('../variable_array', __FILE__)
require File.expand_path('../core_extensions', __FILE__)
require File.expand_path('../matcher', __FILE__)
require File.expand_path('../comparator', __FILE__)
require File.expand_path('../hash', __FILE__)

class HashDealer
  
  attr_accessor :parent
  attr_accessor :optional_attributes

  # cattr_accessor
  def self.hashes
    @hashes ||= {}
  end
  
  # define a method of the request factory
  def self.define(name, opts = {},  &block)
    self.hashes[name] = [opts, block]
  end
  
  def self.roll(name, overrides = {})
    raise Exception.new("No HashDealer called #{name}") unless self.hashes[name]
    self.hashes[name] = self.new(self.hashes[name][0], &self.hashes[name][1]) unless self.hashes[name].is_a?(HashDealer)

    self.hashes[name]._attributes(overrides)
  end
  
  # initializer just calls the block from within our DSL
  def initialize(opts = {}, &block)
    @parent = opts[:parent]
    @optional_attributes = []
    instance_eval(&block)
  end
  
  # set the value as the root element for attributes
  def root(value)
    @attributes = value
  end

  def [](val)
    @attributes[val]
  end
  
  # get the stored attributes for this HashDealer
  def _attributes(overrides)
    # allows us to set a root value
    return @attributes.clone unless @attributes.is_a?(Hash)

    if @parent.present?
      att = HashDealer.roll(@parent.to_sym)
    else
      att = HashDealer::Hash.new(self.optional_attributes)
    end

    @attributes.each do |k,v|
      att[k] = v.is_a?(Proc) ? v.call(att.merge(overrides)) : v
    end
    # if we have a hash as the first arg, it would override the attributes
    overrides.each_pair do |k,v|
      att[k.to_sym] = v if att.has_key?(k.to_sym)
    end
    att
  end
  
  protected
  
  # method missing
  def method_missing(meth, *args, &block)

    unless args.length > 0 || block_given?
      raise Exception.new(
        "Please provide either a String or a block to #{meth}"
      )
    end
    # a second arg is the options hash
    opts = args[1] || {}
    
    # the value is the first arg
    value = args[0]
    
    if opts[:optional]
      @optional_attributes << meth.to_sym
    end

    @attributes ||= Hash.new
    
    if block_given?
      @attributes[meth.to_sym] = block
    else
      @attributes[meth.to_sym] = value
    end
  end
end