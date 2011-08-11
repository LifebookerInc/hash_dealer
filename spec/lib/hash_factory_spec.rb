require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HashFactory do

  it "should be able to define parameter sets" do
    HashFactory.define(:valid_request) do
      abc("defg")
      dan("test")
    end
    HashFactory.roll(:valid_request).should eql(:abc => "defg", :dan => "test")
  end
  
  it "should be able to define paramter sets that return variable data" do
    HashFactory.define(:valid_request) do
      abc{[0,1,2,3].sample}
    end
    [0,1,2,3].should include HashFactory.roll(:valid_request)[:abc]
  end
  
  it "should implement inheritance" do
    HashFactory.define(:valid_request) do
      v("my val")
      abc("first val")
    end
    HashFactory.define(:special_valid_request, :parent => :valid_request) do 
      abc("another value")
    end
    HashFactory.roll(:special_valid_request)[:abc].should eql("another value")
    HashFactory.roll(:special_valid_request)[:v].should eql("my val")
  end
  
  it "should provide a way to return an Array as the root element inheritance" do
     HashFactory.define(:array) do
       root([1,2,3])
     end
     HashFactory.roll(:array).should eql([1,2,3])
   end
   
   
  it "should provide arguments to a block when given" do
    HashFactory.define(:variable) do
      abc{|val| val["test"]}
    end
    HashFactory.roll(:variable, {"test" => "123"})[:abc].should eql("123")
  end
  
  it "should overwrite attributes if provided with extra options" do
    HashFactory.define(:variable) do
      abc("test")
    end
    HashFactory.roll(:variable, {"abc" => "123"})[:abc].should eql("123")
  end
  
  

end