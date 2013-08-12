# just in case it's not loaded
require 'rspec/core'
require 'pp'


def print_diff(diff, depth = 1)
  puts "#{"\t" * depth}" + "HashDealer::#{diff.first.to_s}".bold.cyan + "\t\t\t\tResponse::#{diff.last.to_s}".bold.yellow if diff.is_a?(Array)
  if diff.is_a?(Hash)
    diff.each_pair do |k, v|
      puts "\n"
      puts (("\t" * depth) + k.to_s).red
      print_diff(v, depth + 1)
    end
  end
end

RSpec::Matchers.define(:match_response) do |actual|

  actual = Comparator.normalize_value(actual)

  match do |expected|
    expected = Comparator.normalize_value(expected)
    @diff = Comparator.diff(actual, expected)
    @diff == {}
  end

  failure_message_for_should do |container|
    puts "\n"
    print_diff(@diff)
    puts "\n"
    ""
  end

  failure_message_for_should_not do |container|
    puts "\n"
    print_diff(@diff)
    puts "\n"
    ""
  end
end

# alias as match_json
RSpec::Matchers.define(:match_list) do |actual|

  actual = Comparator.normalize_value(actual)

  match do |expected|
    expected = Comparator.normalize_value(expected)
    expected = expected.first if expected.is_a?(Array)
    actual = actual.first if actual.is_a?(Array)
    @diff = Comparator.diff(actual, expected)
    @diff == {}
  end

  failure_message_for_should do |container|
    puts "\n"
    print_diff(@diff)
    puts "\n"
    ""
  end

  failure_message_for_should_not do |container|
    puts "\n"
    print_diff(@diff)
    puts "\n"
    ""
  end

end