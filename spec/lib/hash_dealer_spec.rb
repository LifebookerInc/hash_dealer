require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HashDealer do

  it "should be able to define parameter sets" do
    HashDealer.define(:valid_request) do
      abc("defg")
      dan("test")
    end
    HashDealer.roll(:valid_request).should eql(:abc => "defg", :dan => "test")
  end
  
  it "should be able to define paramter sets that return variable data" do
    HashDealer.define(:valid_request) do
      abc{[0,1,2,3].sample}
    end
    [0,1,2,3].should include HashDealer.roll(:valid_request)[:abc]
  end
  
  it "should implement inheritance" do
    HashDealer.define(:valid_request) do
      v("my val")
      abc("first val")
    end
    HashDealer.define(:special_valid_request, :parent => :valid_request) do 
      abc("another value")
    end
    HashDealer.roll(:special_valid_request)[:abc].should eql("another value")
    HashDealer.roll(:special_valid_request)[:v].should eql("my val")
  end
  
  it "should provide a way to return an Array as the root element inheritance" do
     HashDealer.define(:array) do
       root([1,2,3])
     end
     HashDealer.roll(:array).should eql([1,2,3])
   end
   
   
  it "should provide arguments to a block when given" do
    HashDealer.define(:variable) do
      abc{|val| val["test"]}
    end
    HashDealer.roll(:variable, {"test" => "123"})[:abc].should eql("123")
  end
  
  it "should overwrite attributes if provided with extra options" do
    HashDealer.define(:variable) do
      abc("test")
    end
    HashDealer.roll(:variable, {"abc" => "123"})[:abc].should eql("123")
  end
  
  

end