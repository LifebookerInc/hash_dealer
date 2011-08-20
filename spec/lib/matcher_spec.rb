require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "match_resonse Matcher" do

  it "should match hashes" do
    {:a => "b"}.should match_response({"a" => ":test"})
  end
  
  it "should match paths within hashes" do
    {:a => {:b => "/test/test"}}.should match_response({"a" =>{"b" => "/:a/:b"}})
  end
  
  it "should match the first element in a list" do
    {"a" => ":b"}.should match_list([{"a" => "test"}, {"a" => "test2"}])
  end
  
end