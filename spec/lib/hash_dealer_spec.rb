require 'json'
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
  
  context "Matchers" do
  
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
    
    context "Dates and Times" do
      before(:all) do
        HashDealer.define(:variable) do
          time_test(Time.now)
          date_test(Date.today)
        end
        HashDealer.define(:var) do
          id("1")
          created_at(Time.now)
          updated_at(Time.now)
        end
      end
      it "should create a wrapper for times and dates" do


        time_test = HashDealer.roll(:variable).matcher[:time_test]
        date_test =  HashDealer.roll(:variable).matcher[:date_test]

        time_test.should be_instance_of TimeDateMatcher
        date_test.should be_instance_of TimeDateMatcher

        time_test.should eql (Time.now - 1000)
        time_test.should_not eql (Date.today)
        date_test.should eql (Date.today)
        date_test.should_not eql (Time.now)

        # check the reverse too
        (Time.now - 1000).should eql(time_test)
        (Time.now - 1000).should == time_test
        (Date.today).should_not eql(time_test)
        (Date.today).should_not == time_test

        # regular behavior should be unaffected
        t = Time.now
        t.should eql t.clone
        t.should == t.clone


      end

      it "should match dates and times from JSON" do
        ActiveSupport::JSON.encode({:created_at => Time.now, :updated_at => Time.now, :id => 1}).should match_response(HashDealer.roll(:var).matcher)
      end

      it "should allow dates and times to be null" do
        ActiveSupport::JSON.encode({:created_at => nil, :updated_at => nil, :id => 1}).should match_response(HashDealer.roll(:var).matcher)
      end
      
    end
    
    
    
    it "should not modify the element when returning a matcher" do
      HashDealer.define(:array) do
        my_array([1,2,3])
      end
      HashDealer.roll(:array).matcher[:my_array].should eql ([":matcher",1,2,3])
      HashDealer.roll(:array)[:my_array].should eql ([1,2,3])
    end
    
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
  
  it "should match on numeric values" do
    HashDealer.define(:parent) do
      a(1)
    end
    HashDealer.roll(:parent).matcher[:a].should eql 100
    HashDealer.roll(:parent)[:a].should_not eql 100
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
  
  it "should allow the use of a HashDealer in the definition of another before the first is defined" do
    HashDealer.define(:b) do
      hash_a(HashDealer.roll(:a))
    end
    HashDealer.define(:a) do
      a("123")
    end
    HashDealer.roll(:b).should eql({:hash_a => {:a => "123"}})
  end
  
  it "should allow nested blocks of attributes" do
    HashDealer.roll(:b).should eql({:hash_a => {:a => "123"}})
  end

  it "should have access to its current values when setting a value" do
    HashDealer.define(:dynamic_values) do
      parent_value{ "x" }
      child_value{|record| record[:parent_value]}
    end

    data = HashDealer.roll(:dynamic_values)
    data[:child_value].should eql("x")

  end

  context "nil and false values" do
    it "should allow nil and false values" do
      HashDealer.define(:with_nil_and_false_values) do
        nil_value nil
        false_value false
      end
      HashDealer.roll(:with_nil_and_false_values).should eql({
        :nil_value => nil,
        :false_value => false
      })
    end
  end
  
  context "optional values" do

    it "should allow values to be optionally passed in" do
      HashDealer.define(:with_optional_values) do
        required_value "x"
        optional_value "y", :optional => true
      end

      hd = HashDealer.roll(:with_optional_values)

      hd.should eql({:required_value => "x"})
      hd.should eql({:required_value => "x", :optional_value => "y"})
      hd.should_not eql({:optional_value => "y"})
      hd.should_not eql({:required_value => "x", :bad_value => "z"})

    end

  end

  
end