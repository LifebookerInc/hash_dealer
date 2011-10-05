# just in case it's not loaded
require 'rspec'
require 'pp'

RSpec::Matchers.define(:match_response) do |actual|
  
  actual = Comparator.normalize_value(actual)
  
  match do |expected|
    expected = Comparator.normalize_value(expected)
    Comparator.diff(actual, expected) == {}
  end
  
  failure_message_for_should do |container|
    Comparator.diff(actual, expected).pretty_inspect
  end
  
  failure_message_for_should_not do |container|
    Comparator.diff(actual, expected).pretty_inspect
  end
end

# alias as match_json
RSpec::Matchers.define(:match_list) do |actual|
  
  actual = Comparator.normalize_value(actual)
  
  match do |expected|
    expected = Comparator.normalize_value(expected)
    expected = expected.first if expected.is_a?(Array)
    actual = actual.first if actual.is_a?(Array)
    Comparator.diff(actual, expected) == {}
  end
    
  failure_message_for_should do |container|
    Comparator.diff(actual, expected).pretty_inspect
  end
  
  failure_message_for_should_not do |container|
    Comparator.diff(actual, expected).pretty_inspect
  end
  
end