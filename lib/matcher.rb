# just in case it's not loaded
require 'rspec'

RSpec::Matchers.define(:match_response) do |actual|
  
  match do |expected|
    PathString.as_sorted_json(actual) == PathString.as_sorted_json(expected)
  end
  
  failure_message_for_should do |container|
    "expected #{PathString.as_sorted_json(actual)}\n to equal\n #{PathString.as_sorted_json(container)}"
  end
  
  failure_message_for_should_not do |container|
    "expected #{PathString.as_sorted_json(actual)}\n not to equal\n #{PathString.as_sorted_json(container)}"
  end
  
end

# alias as match_json
RSpec::Matchers.define(:match_list) do |actual|
  
  match do |expected|
    actual = JSON.parse(actual) if actual.is_a?(String)
    expected = JSON.parse(expected) if expected.is_a?(String)  
    actual = actual.first if actual.is_a?(Array)
    expected = expected.first if expected.is_a?(Array)
    PathString.as_sorted_json(actual) == PathString.as_sorted_json(expected)
  end
    
  failure_message_for_should do |container|
    "expected #{PathString.as_sorted_json(actual)}\n to equal\n #{PathString.as_sorted_json(container)}"
  end
  
  failure_message_for_should_not do |container|
    "expected #{PathString.as_sorted_json(actual)}\n not to equal\n #{PathString.as_sorted_json(container)}"
  end
  
end