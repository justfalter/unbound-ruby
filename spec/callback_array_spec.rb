require 'spec_helper'

describe Unbound::CallbackArray do
  before :each do
    @cba = Unbound::CallbackArray.new
  end

  describe "#add_callback" do
    it "should raise an ArgumentError if no callback is provided" do
      expect { 
        @cba.add_callback()
      }.to raise_error(ArgumentError)
    end
    it "should accept a callback as an argument" do
      proc1 = Proc.new {}
      @cba.add_callback(proc1)
      expect(@cba).to eq([proc1])
    end
    it "should accept a callback as block" do
      proc1 = Proc.new {}
      @cba.add_callback(&proc1)
      expect(@cba).to eq([proc1])
    end
    it "should accept multiple callbacks as arguments in order" do
      proc1 = Proc.new {}
      proc2 = Proc.new {}
      proc3 = Proc.new {}
      proc4 = Proc.new {}
      proc5 = Proc.new {}
      @cba.add_callback(proc1, proc2, proc3, proc4, proc5)
      expect(@cba).to eq([proc1, proc2, proc3, proc4, proc5])
    end
    it "should preserve order" do
      proc1 = Proc.new {}
      proc2 = Proc.new {}
      proc3 = Proc.new {}
      proc4 = Proc.new {}
      proc5 = Proc.new {}
      @cba.add_callback(proc1)
      @cba.add_callback(proc2)
      @cba.add_callback(proc3)
      @cba.add_callback(proc4)
      @cba.add_callback(proc5)
      expect(@cba).to eq([proc1, proc2, proc3, proc4, proc5])
    end
    it "should arguments and blocks at the same time" do
      proc1 = Proc.new {}
      proc2 = Proc.new {}
      proc3 = Proc.new {}
      proc4 = Proc.new {}
      proc5 = Proc.new {}
      @cba.add_callback(proc1, proc2, proc3, proc4, &proc5)
      expect(@cba).to eq([proc1, proc2, proc3, proc4, proc5])
    end
  end
  describe "#call" do
    it "should arguments and blocks at the same time" do
      expect { |cb1|
        expect { |cb2|
          expect { |cb3|
            expect { |cb4|
              @cba.add_callback(cb1.to_proc, cb2.to_proc, cb3.to_proc, cb4.to_proc)
              @cba.call(1,2,3)
            }.to yield_with_args(1,2,3)
          }.to yield_with_args(1,2,3)
        }.to yield_with_args(1,2,3)
      }.to yield_with_args(1,2,3)
    end
  end
end

