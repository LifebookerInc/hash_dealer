require 'path_string'
require 'core_extensions'
require 'matcher'

class HashDealer
  
  attr_accessor :parent

  # cattr_accessor
  def self.hashes
    @hashes ||= {}
  end
  
  # define a method of the request factory
  def self.define(name, opts = {},  &block)
    self.hashes[name] = self.new(opts, &block)
  end
  
  def self.roll(name, *args)
    raise Exception.new("No HashDealer called #{name}") unless self.hashes[name]
    self.hashes[name].attributes(*args)
  end
  
  # initializer just calls the block from within our DSL
  def initialize(opts = {}, &block)
    @parent = opts[:parent]
    instance_eval(&block)
  end
  
  # set the value as the root element for attributes
  def root(value)
    @attributes = value
  end
  
  # method missing
  def method_missing(meth, *args, &block)
    raise Exception.new("Please provide either a String or a block to #{meth}") unless (args.length == 1 || (args.empty? && block_given?))
    @attributes ||= {}
    if block_given?
      @attributes[meth.to_sym] = block
    else
      @attributes[meth.to_sym] = args.first
    end
  end
  
  def attributes(*args)
    # allows us to set a root value
    return @attributes unless @attributes.is_a?(Hash)
    att = @parent ? HashDealer.roll(@parent.to_sym) : {}
    @attributes.each do |k,v|
      att[k] = v.is_a?(Proc) ? v.call(*args) : v
    end
    # if we have a hash as the first arg, it would override the attributes
    if args.first.is_a?(Hash)
      args.first.each_pair do |k,v|
        att[k.to_sym] = v if att.has_key?(k.to_sym)
      end
    end
    att
  end
  
end