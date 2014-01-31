require 'spec_helper'

describe Unbound::Resolver do
  before :each do
    @context = Unbound::Context.new
    @resolver = Unbound::Resolver.new(@context)
  end

  after :each do
    @resolver.close unless @resolver.closed?
  end
  
  describe "#cancel_all" do
    it "should cancel all queries"  do
      query1 = Unbound::Query.new("localhost", 1, 1)
      expect { |cb|
        query1.on_cancel(cb.to_proc)
        @resolver.send_query(query1)
        @resolver.cancel_all
      }.to yield_control
    end
  end

  describe "#outstanding_queries" do
    it "should return the number of outstanding queries"  do
      expect(@resolver.outstanding_queries).to eq(0)
      10.times do
        query = Unbound::Query.new("localhost", 1, 1)
        @resolver.send_query(query)
      end
      expect(@resolver.outstanding_queries).to eq(10)
      @resolver.cancel_all
      expect(@resolver.outstanding_queries).to eq(0)
    end
  end

  describe "#outstanding_queries?" do
    it "should be false if there are no outstanding queries"  do
      expect(@resolver.outstanding_queries?).to be_false
    end

    it "should be true if there are any outstanding queries"  do
      query = Unbound::Query.new("localhost", 1, 1)
      @resolver.send_query(query)
      expect(@resolver.outstanding_queries?).to be_true
    end
  end

  describe "#closed?" do
    it "should not be closed by default"  do
      expect(@resolver.closed?).to be_false
    end
    it "should be closed after calling #close" do
      @resolver.close
      expect(@resolver.closed?).to be_true
    end
  end

  describe "#close" do
    it "should call #cancel_all" do
      @resolver.should_receive(:cancel_all).and_call_original
      @resolver.close
    end

    it "should close the context" do
      @context.should_receive(:close).and_call_original
      @resolver.close
    end
  end

  describe "#io" do
    it "should return an IO object" do
      expect(@resolver.io).to be_a(::IO)
    end
  end

  describe "#process" do
    it "should call our callback" do
      query1 = Unbound::Query.new("localhost", 1, 1)
      expect { |cb|
        query1.on_answer(cb.to_proc)
        @resolver.send_query(query1)
        io = @resolver.io
        expect(::IO.select([io], nil, nil, 5)).to_not be_nil
        @resolver.process
      }.to yield_control
    end
  end

  describe "#send_query" do
    it "should raise an exception if the same query object is submitted twice" do
      query1 = Unbound::Query.new("localhost", 1, 1)
      @resolver.send_query(query1)
      expect {@resolver.send_query(query1)}.to raise_error
    end
  end

  describe "#on_start" do
    specify "callbacks should be called when send_query is called" do
      query = Unbound::Query.new("localhost", 1, 1)
      expect { |cb|
        @resolver.on_start(&cb)
        @resolver.send_query(query)
      }.to yield_with_args(query)
    end
  end

  describe "#on_answer" do
    specify "callbacks should be called if the query has been answered" do
      query = Unbound::Query.new("localhost", 1, 1)
      result = double("Result")
      expect { |cb|
        @resolver.on_answer(&cb)
        @resolver.send_query(query)
        query.answer!(result)
      }.to yield_with_args(query, result)
    end
  end

  describe "#on_error" do
    specify "callbacks should be called if the query has an error" do
      query = Unbound::Query.new("localhost", 1, 1)
      result = double("Result")
      expect { |cb|
        @resolver.on_error(&cb)
        @resolver.send_query(query)
        query.error!(1234)
      }.to yield_with_args(query, 1234)
    end
  end

  describe "#on_cancel" do
    specify "callbacks should be called if the query has been canceled" do
      query = Unbound::Query.new("localhost", 1, 1)
      result = double("Result")
      expect { |cb|
        @resolver.on_cancel(&cb)
        @resolver.send_query(query)
        query.cancel!()
      }.to yield_with_args(query)
    end
  end

  describe "#on_finish" do
    specify "callbacks should be called if the query is finished for any reason" do
      query = Unbound::Query.new("localhost", 1, 1)
      result = double("Result")
      expect { |cb|
        @resolver.on_finish(&cb)
        @resolver.send_query(query)
        query.cancel!()
      }.to yield_with_args(query)
    end
  end
end

