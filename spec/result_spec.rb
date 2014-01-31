require 'spec_helper'

describe Unbound::Result do
  extend UnboundHelper
  UDP_RESPONSE = hex2bin("44438180000100060000000003777777057961686f6f03636f6d0000010001c00c0005000100000121000f0666642d667033037767310162c010c02b000500010000012100090664732d667033c032c046000500010000003100150e64732d616e792d6670332d6c666203776131c036c05b000500010000012100120f64732d616e792d6670332d7265616cc06ac07c00010001000000310004628bb718c07c00010001000000310004628bb495")

  describe "#to_resolv" do
    it "should return nil if there is no data" do
      result = Unbound::Result.new
      expect(result.to_resolv).to be_nil
    end
    it "should return a resolv object if there is data" do
      result = Unbound::Result.new
      packet_ptr = FFI::MemoryPointer.from_string(UDP_RESPONSE)
      result[:answer_packet] = packet_ptr
      result[:answer_len] = packet_ptr.size
      expect(result.to_resolv).to be_a(Resolv::DNS::Message)
    end
  end
end

