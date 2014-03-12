require 'spec_helper'

describe Unbound::Context do
  before :each do
    @ctx = Unbound::Context.new
  end

  after :each do
    @ctx.close unless @ctx.closed?
  end

  subject { @ctx }
  its(:raise_on_noid?) { should be_false }


  it "should let me indicate that it should raise an error if the error code is :noid" do
    @ctx.raise_on_noid = true
    expect(@ctx.raise_on_noid?).to be_true
  end

  describe "#closed?" do
    it "should indicate whether the context is closed or not" do
      expect(@ctx.closed?).to be_false
      @ctx.close
      expect(@ctx.closed?).to be_true
    end
  end

  describe "#close" do
    it "should delete the underlying context" do
      Unbound::Bindings.should_receive(:ub_ctx_delete)
      @ctx.close
    end

    it "should raise an Unbound::ContextClosedError if we try to close it more than once" do
      @ctx.close
      expect(lambda do
        @ctx.close
      end).to raise_error(Unbound::ContextClosedError)
    end

    it "should raise an Unbound::ContextClosedError if we make an API call after the context is closed." do
      @ctx.close
      expect(lambda do
        @ctx.fd
      end).to raise_error(Unbound::ContextClosedError)
    end
  end

  it "should let me set and retrieve unbound configuration options" do
    @ctx.set_option("do-ip6", "no")
    expect(@ctx.get_option("do-ip6")).to eq("no")
    @ctx.set_option("do-ip6", "yes")
    expect(@ctx.get_option("do-ip6")).to eq("yes")
  end

  describe "#load_config" do
    it "should load a proper unbound configuration file" do
      @ctx.set_option("do-ip6", "no")
      expect(@ctx.get_option("do-ip6")).to eq("no")
      @ctx.load_config(UnboundHelper.config_file("test_config.conf"))
      expect(@ctx.get_option("do-ip6")).to eq("yes")
      expect(@ctx.get_option("version")).to eq("test config loaded!")
    end

    it "should raise an Unbound::APIError if the configuration file was not found" do
      expect(lambda do
        @ctx.load_config(UnboundHelper.config_file("this_config_doesnt_exist.conf"))
      end).to raise_error(Unbound::APIError)
    end
  end

  shared_examples_for "an asynchronous name resolution method" do
    # expects:
    #   @processing_proc = A Proc
    #   @ctx 
    before :each do
      @ctx.load_config(UnboundHelper.config_file("local_zone.conf"))
      expect(1).to be(1)

      @cb_result_ptr = nil
      @cb_err = nil
      @cb_mydata = nil

      @cb = Proc.new do |mydata, err, result_ptr|
        @cb_mydata = mydata
        @cb_err = err
        @cb_result_ptr = result_ptr
      end
    end

    describe "resolving mycomputer.local IN A" do
      before :each do
        @async_id = @ctx.resolve_async("mycomputer.local", 1, 1, @cb)
        @processing_proc.call()
      end

      it "should have an error in the callback" do
        expect(@cb_err).to be(0)
      end

      it "should have a result_ptr" do
        expect(@cb_result_ptr).not_to be_nil
      end

      describe "result.to_resolv" do
        subject {Unbound::Result.new(@cb_result_ptr).to_resolv}
        its(:rcode) {should eq(0)}

        it "should have the proper answer" do
          expect(subject.answer.length).to be(1)
          answer = subject.answer[0]
          expect(answer[0].to_s).to eq("mycomputer.local")
          expect(answer[2].address.to_s).to eq("192.0.2.51")
        end
      end
    end
    describe "#cancel_async_query" do
      before :each do
        @async_id = @ctx.resolve_async("mycomputer.local", 1, 1, @cb)
      end

      it "should cancel a query" do
        expect(@ctx.cancel_async_query(@async_id)).to be(:noerror)
      end
      
      it "should raise an APIError when canceling a non-existent query" do
        @ctx.raise_on_noid = true 
        expect(@ctx.raise_on_noid?).to be_true
        expect(lambda do 
          @ctx.cancel_async_query(@async_id + 1)
        end).to raise_error(Unbound::APIError)
      end

      it "#raise_on_noid=false should raise an APIError when canceling a non-existent query" do
        expect(@ctx.raise_on_noid?).to be_false
        expect(@ctx.cancel_async_query(@async_id + 1)).to eq(:noid)
      end
    end
  end

  describe "#io" do
    it "should return an IO object" do
      expect(@ctx.io).to be_a(::IO)
    end

    it "should return a new IO object for each call" do
      expect(@ctx.io).not_to be(@ctx.io)
    end
  end

  describe "asynchronous query processing via select/process" do
    before :each do
      @processing_proc = lambda do
        fd = @ctx.fd
        io = @ctx.io
        ret = ::IO.select([io], nil, nil, 5)
        expect(ret).not_to be_nil
        @ctx.process
      end
    end
    it_should_behave_like "an asynchronous name resolution method"
  end
end

