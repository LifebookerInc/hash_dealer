$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bundler'
require 'hash_dealer'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Bundler.require(:default, :development)

Debugger.start

Dir[File.join(File.dirname(__FILE__), '..', 'spec/support/**/*.rb')].each {|f| require f}

