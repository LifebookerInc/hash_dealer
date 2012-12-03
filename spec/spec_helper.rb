require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'spec'
end

SimpleCov.at_exit do
  SimpleCov.result.format!
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bundler'
require 'hash_dealer'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Bundler.require(:default, :development)

Debugger.start

Dir[File.join(File.dirname(__FILE__), '..', 'spec/support/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
