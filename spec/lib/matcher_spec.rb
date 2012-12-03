require 'json'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "match_response Matcher" do

  it "should match hashes" do
    {:a => "b"}.should match_response({"a" => "test"}.matcher)
  end
  
  it "should match paths within hashes" do
    String.new({"a" =>{"b" => "/:a/:b"}}.matcher["a"]["b"]).should eql "/:a/:b"
    {:a => {:b => "/test/test"}}.should match_response({"a" =>{"b" => "/:a/:b"}}.matcher)
  end
  
  it "should match the first element in a list" do
    [{"a" => "test"}, {"a" => "test2"}].should match_list({"a" => "b"}.matcher)
  end
  
  it "should account for the first :matcher param when it's at the root" do
    JSON.unparse([{"a" => "b"}, {"a" => "c"}]).should match_list({"a" => "b"}.matcher)
  end
  
  it "should match using wildcards for variable length arrays" do
    {"a" => ["a"]}.matcher.should match_response({"a" => ["a", "b", "c", "d"]})
    {"a" => [{"a" => "b"}]}.matcher.should match_response({"a" => [{"a" => "c"},{"a" => "x"},{"a" => "y"}]})
  end
  
  it "should stringify keys so it matches symbols to strings" do
    {:a => "a"}.matcher.should match_response({"a" => "abcde"})
    {:a => {:b => "c"}}.should match_response({"a" => {"b" => "c"}})
  end
  
  context ".diff" do

    it "should provide meaningful diffs" do
      h1 = {:a => {:b => "c", :d => "e"}}
      h2 = {:a => {:b => "d", :d => "e"}, :b => "test"}
      diff = Comparator.diff(h1, h2)
      diff.should eql({
        "a" => {"b" => ["c", "d"]}, 
        "b" => ["KEY MISSING", "test"]
      })
    end

    it "should match hashes regardless of the order of the keys" do
      Comparator.diff({"a" => {"b" => "c", "d" => "e"}, "b" => "c"}, {:b => "c", :a => {"d" => "e", :b => "c"}}).should eql({})
    end
    
    it "should use the matcher comparison inside of Comparator" do
      Comparator.diff({"a" => "dkddk"}.matcher, {"a" => "test"}).should eql({})
      Comparator.diff({"a" => "dkddk"}, {"a" => "test"}.matcher).should eql({})
    end

    it "should provide meaningful diffs for arrays" do
      h1 = {
        :a => [{"1" => "3"}]
      }
      h2 = {
        :a => [{"2" => "4"}]
      }
      diff = Comparator.diff(h1.matcher, h2)
      diff.should eql({
        "a" => {
          0 => {
            "1" => ["3", "KEY MISSING"], 
            "2" => ["KEY MISSING", "4"]
          }
        }
      })
      true
    end


  end
  
  
  
  it "should recursively set hash keys to strings" do
    Comparator.normalize_value({:x => [[{:y => "z"}]]})["x"].first.first["y"].should eql "z"
  end
  
  it "should convert booleans to a matcher class that evaluates to either true or false" do
    {"a" => true}.matcher.should match_response({"a" => false})
    {"a" => {"b" => false}}.matcher.should match_response({"a" => {"b" => false}})
  end
  
  it "should return a diff when either argument is missing a key" do
    Comparator.diff({"a" => true, "b" => false}, {"a" => true}).should eql({"b" => [false, "KEY MISSING"]})
    Comparator.diff({"a" => true}, {"a" => true, "b" => false}).should eql({"b" => ["KEY MISSING", false]})
  end
  
end