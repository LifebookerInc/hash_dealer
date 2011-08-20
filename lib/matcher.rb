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
RSpec::Matchers.define(:match_json) do |actual|
  
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