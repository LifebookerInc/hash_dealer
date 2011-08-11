require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PathString do

  it "should match values with a ':' as wildcards" do
    PathString.new(":test").should == PathString.new("abcdefg")
  end
  it "should work on nested hashes and arrays" do
    PathString.as_sorted_json(:abc => [":1",":2",":3"]).should == PathString.as_sorted_json({:abc => ["1","2","3"]})
    a = {
      "provider[address][address_name]" => ":name", 
      "provider[address][city]" => ":city", 
      "provider[address][state]" => ":state", 
      "provider[address][street_line_1]" => ":street", 
      "provider[address][zip]" => ":zip", 
      "provider[current_step]" => "2", 
      "provider[payment_type_ids]" => [":id"], 
      "provider[statement_of_business]" => ":statement", 
      "provider[url]" => ":url"
    }
    b = {
      "provider[address][address_name]" => "Brady+Rowe", 
      "provider[address][city]" => "New+York", 
      "provider[address][state]" => "NY", 
      "provider[address][street_line_1]" => "708+Kutch+Squares", 
      "provider[address][zip]" => "10024", 
      "provider[current_step]" => "2", 
      "provider[payment_type_ids]" => ["1"], 
      "provider[statement_of_business]" => "Hic+nulla+tempora+voluptatibus+nemo.+Mollitia+qui+deleniti+rerum.+Ut+omnis+adipisci+eos.", 
      "provider[url]" => "http%3A%2F%2Ffoo.com"
    }
  
    PathString.as_sorted_json(a).should == PathString.as_sorted_json(b)
  end
  
  it "should match wildcard paths" do
    PathString.paths_match?("/a/1/test/2", "/a/:1/test/:2").should be_true
  end
  
end