# just in case it's not loaded
require 'rspec'
require 'pp'

RSpec::Matchers.define(:match_response) do |actual|
  
  match do |expected|
    PathString.as_sorted_json(actual) == PathString.as_sorted_json(expected)
  end
  
  failure_message_for_should do |container|
    "expected #{PathString.as_sorted_json(actual).pretty_inspect}\n to equal\n #{PathString.as_sorted_json(container).pretty_inspect} \n\n Diff: \n #{PathString.diff(container, actual)}"
  end
  
  failure_message_for_should_not do |container|
    "expected #{PathString.as_sorted_json(actual).pretty_inspect}\n not to equal\n #{PathString.as_sorted_json(container).pretty_inspect} \n\n Diff: \n #{PathString.diff(container, actual)}"
  end
end

# alias as match_json
RSpec::Matchers.define(:match_list) do |actual|
  
  def normalize(val)
    val = JSON.parse(val) if val.is_a?(String)
    # if it's an array, we want just the first value   
    if val.is_a?(Array)
      # we append :matcher to account for variable length arrays - that causes a problem
      # when the array is at the root and we are looking for the first element
      val = val.first == ":matcher" ? val[1] : val.first 
    end
    val
  end
  
  match do |expected|
    PathString.as_sorted_json(normalize(actual)) == PathString.as_sorted_json(normalize(expected))
  end
    
  failure_message_for_should do |container|
    "expected #{PathString.as_sorted_json(normalize(actual))}\n to equal\n #{PathString.as_sorted_json(normalize(container))} \n\n Diff: \n #{PathString.diff(container, actual)}"
  end
  
  failure_message_for_should_not do |container|
    "expected #{PathString.as_sorted_json(normalize(actual))}\n not to equal\n #{PathString.as_sorted_json(normalize(container))} \n\n Diff: \n #{PathString.diff(container, actual)}"
  end
  
end