require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "match_resonse Matcher" do

  it "should match hashes" do
    {:a => "b"}.should match_response({"a" => ":test"})
  end
end