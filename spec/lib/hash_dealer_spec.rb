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
  
  it "should extend itself to matchers - preventing us from having to re-define them" do
    HashDealer.define(:variable) do
      abc("test")
      val({
        :k => "v"
      })
    end
    String.new(HashDealer.roll(:variable).matcher[:abc]).should eql ":test"
    String.new(HashDealer.roll(:variable).matcher[:val][:k]).should eql ":v"
  end
  
  it "should not alter fields passed into the matcher method in the except array" do
    HashDealer.define(:variable) do
      a("test_a")
      b("test_b")
    end
    HashDealer.roll(:variable).matcher(:except => [:b])[:a].should eql(":test_a")
    HashDealer.roll(:variable).matcher(:except => [:b])[:b].should eql("test_b")
  end
  
  it "should only alter fields passed into the matcher method in the the only array" do
    HashDealer.define(:variable) do
      a("test_a")
      b("test_b")
    end
    HashDealer.roll(:variable).matcher(:only => [:b])[:a].should eql("test_a")
    HashDealer.roll(:variable).matcher(:only => [:b])[:b].should eql(":test_b")
  end
  
  it "should apply except/only to nested values if they are defined by hash dealer and specified" do
    HashDealer.define(:parent) do
      a("test_a")
      b{HashDealer.roll(:child)}
    end
    HashDealer.define(:child) do
      a("child_a")
      b("child_b")
    end
    HashDealer.roll(:parent).matcher(:only => [:b], :b => {:except => [:a]})[:a].should eql("test_a")
    HashDealer.roll(:parent).matcher(:only => [:b], :b => {:except => [:a]})[:b][:a].should eql("child_a")
    HashDealer.roll(:parent).matcher(:only => [:b], :b => {:except => [:a]})[:b][:b].should eql(":child_b")
  end
  
  it "should define a matcher for when the response is an Array" do
    HashDealer.define(:variable) do
      root([{
        :abc => "123",
        :deff => "1234"
      }])
    end
    HashDealer.roll(:variable).matcher.should eql([{:abc => ":123", :deff => ":1234"}])
  end
  
  it "should return a clone of its attributes, not an actual reference" do
    HashDealer.define(:a) do
      root({:a => "b"})
    end
    HashDealer.define(:b) do
      a "test"
    end
    HashDealer.roll(:a).should_not be HashDealer.roll(:a)
    HashDealer.roll(:b).should_not be HashDealer.roll(:b)
  end

  it "should allow defining a hash where one of the keys is attributes" do
    HashDealer.define(:test) do
      attributes("test")
    end
    HashDealer.roll(:test)[:attributes].should eql("test")
    HashDealer.roll(:test).matcher[:attributes].should eql(":test")
  end
end