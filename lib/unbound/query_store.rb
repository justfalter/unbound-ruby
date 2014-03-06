require 'ffi'

module Unbound
  # Tracks in-flight queries for Resolver
  class QueryStore
    def initialize
      @pointer_to_query_map = {}
    end

    # Enumerates through each query.
    def each
      @pointer_to_query_map.each_value do |query|
        yield(query)
      end
    end

    # Clears all queries from the store. No special actions taken.
    def clear
      @pointer_to_query_map.clear
    end

    # @return [Integer] the number of queries in the store.
    def count
      @pointer_to_query_map.count
    end

    # Retreives the query from the store via the provided pointer.
    # @param [FFI::Pointer] pointer
    # @return [Unbound::Query, nil] The associated query, otherwise nil.
    def get_by_pointer(pointer)
      return nil if pointer.nil?
      @pointer_to_query_map[pointer.address]
    end

    # Stores a query object, and returns a pointer suitable for passing through
    # Unbound::Context#resolve_async.
    # @param [Unbound::Query] query 
    # @return [FFI::Pointer] the pointer
    def store(query)
      oid_ptr = FFI::Pointer.new query.object_id
      @pointer_to_query_map[oid_ptr.address] = query
      oid_ptr
    end

    # Deletes a query object from the store, and frees any associated pointer
    # (if nescessary).
    # @param [Unbound::Query] query
    # @return [Unbound::Query] the query, if it was found. Otherwise nil.
    def delete_query(query)
      @pointer_to_query_map.delete(FFI::Pointer.new(query.object_id).address)
    end
  end
end

