require 'spec_helper'

describe Unbound::QueryStore do
  let(:query_store) {
    Unbound::QueryStore.new
  }

  def new_query(num)
    Unbound::Query.new("somedomain#{num}.com", 1, 1)
  end

  describe "#each" do
    it "should yield as many times as there are queries in the store" do
      5.times do |i|
        query_store.store(new_query(i))
      end
      expect {|b| query_store.each(&b)}.to yield_control.exactly(5).times
    end
    it "should yield the set of query objects we put into it" do
      expected_queries = []
      actual_queries = []
      5.times do |i|
        query = new_query(i)
        expected_queries << query
        query_store.store(query)
      end
      query_store.each do |query|
        actual_queries << query
      end
      expect(actual_queries).to match_array(expected_queries)
    end
    it "should not yield deleted queries" do
      q1 = new_query(1)
      q2 = new_query(2)
      q3 = new_query(3)
      query_store.store(q1)
      query_store.store(q2)
      query_store.store(q3)
      query_store.delete_query(q2)
      remaining_queries = []
      query_store.each do |query|
        remaining_queries << query
      end
      expect(remaining_queries).to match_array([q1, q3])
    end
  end
  describe "#clear" do
    it "should cause the count to drop to 0" do
      expect(query_store.count).to eq(0)
      5.times do |i|
        query_store.store(new_query(i))
      end
      expect(query_store.count).to eq(5)
      query_store.clear
      expect(query_store.count).to eq(0)
    end
    it "should remove all queries from the store, making it so they cannot be retreived" do
      queries = {}
      5.times do |i|
        query = new_query(i)
        ptr = query_store.store(query)
        queries[ptr] = query
      end

      queries.each_pair do |ptr, query|
        expect(query_store.get_by_pointer(ptr)).to be(query)
      end

      query_store.clear
      queries.each_pair do |ptr, query|
        expect(query_store.get_by_pointer(ptr)).to be_nil
      end
    end
  end
  describe "#count" do
    it "should be 0 if there's nothing in there" do
      expect(query_store.count).to eq(0)
    end
    it "should be 5 if five distinct queries have been added" do
      5.times do |i|
        query_store.store(new_query(i))
      end
      expect(query_store.count).to eq(5)
    end
    it "should be 1 if the same query was added 5 times" do
      query = new_query(1)
      5.times do |i|
        query_store.store(query)
      end
      expect(query_store.count).to eq(1)
    end
  end
  describe "#store" do 
    it "should return a pointer" do
      expect(query_store.store(new_query(1))).to be_a(FFI::Pointer)
    end
    it "should increase the count" do
      query = new_query(1)
      expect(query_store.count).to eq(0)
      query_store.store(query)
      expect(query_store.count).to eq(1)
    end
  end
  describe "#get_by_pointer" do
    it "should return the query associated with the provided pointer" do
      query1 = new_query(1)
      query2 = new_query(2)
      query3 = new_query(3)
      query4 = new_query(4)
      query5 = new_query(5)
      ptr1 = query_store.store(query1)
      ptr2 = query_store.store(query2)
      ptr3 = query_store.store(query3)
      ptr4 = query_store.store(query4)
      ptr5 = query_store.store(query5)
      expect(query_store.get_by_pointer(ptr1)).to be(query1)
      expect(query_store.get_by_pointer(ptr2)).to be(query2)
      expect(query_store.get_by_pointer(ptr3)).to be(query3)
      expect(query_store.get_by_pointer(ptr4)).to be(query4)
      expect(query_store.get_by_pointer(ptr5)).to be(query5)
    end
    it "should return nil if the provided pointer is not associated with a query" do
      expect(query_store.get_by_pointer(FFI::Pointer.new(1234))).to be_nil
    end
  end
  describe "#delete_query" do
    it "should make it so the query can no longer be retreived from the store" do
      query1 = new_query(1)
      query2 = new_query(2)
      ptr1 = query_store.store(query1)
      ptr2 = query_store.store(query2)
      expect(query_store.get_by_pointer(ptr1)).to be(query1)
      expect(query_store.get_by_pointer(ptr2)).to be(query2)
      query_store.delete_query(query1)
      expect(query_store.get_by_pointer(ptr1)).to be_nil
      expect(query_store.get_by_pointer(ptr2)).to be(query2)
      query_store.delete_query(query2)
      expect(query_store.get_by_pointer(ptr1)).to be_nil
      expect(query_store.get_by_pointer(ptr2)).to be_nil
    end
    it "should return the query that was deleted" do
      query1 = new_query(1)
      ptr1 = query_store.store(query1)
      expect(query_store.delete_query(query1)).to be(query1)
    end
    it "should return nil if the query was not in the store" do
      query1 = new_query(1)
      expect(query_store.delete_query(query1)).to be_nil
    end
  end
end


