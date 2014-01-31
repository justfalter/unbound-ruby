require 'spec_helper'

describe Unbound::Query do
  context "a query for google.com IN A" do
    before :each do
      @rrtype = 1
      @rrclass = 1
      @name = "google.com"
      @query = Unbound::Query.new(@name, @rrtype, @rrclass)
    end

    subject {@query}
    its(:name) { should eq("google.com") }
    its(:rrtype) { should eq(1) }
    its(:rrclass) { should eq(1) }
    its(:finished?) { should be_false }

    describe "#start!" do
      its "should set the async_id" do
        expect(@query.async_id).to be_nil
        @query.start!(1234)
        expect(@query.async_id).to eq(1234)
      end
    end
    describe "#started?" do
      its "should be false by default" do
        expect(@query.started?).to be_false
      end
      its "should be true after start! is called" do
        @query.start!(1234)
        expect(@query.started?).to be_true
      end
    end
    describe "#on_start" do
      its "should be called after start! is called" do
        expect { |cb|
          @query.on_start(cb.to_proc)
          @query.start!(1234)
        }.to yield_with_args(@query)
      end
    end
    describe "#on_error" do
      its "should raise an ArgumentError if no callback is provided" do
        expect { |cb|
          @query.on_error()
        }.to raise_error(ArgumentError)
      end
      its "should not be called after timeout! is called" do
        expect { |cb|
          @query.on_error(cb.to_proc)
          @query.timeout!()
        }.to_not yield_control
        expect(@query).to be_finished
      end
      its "should not called after success! is called" do
        result = double("Result")
        expect { |cb|
          @query.on_error(cb.to_proc)
          @query.success!(result)
        }.to_not yield_control
        expect(@query).to be_finished
      end
      its "should be called after error! is called" do
        expect { |cb|
          @query.on_error(cb.to_proc)
          @query.error!(:some_symbol)
        }.to yield_with_args(@query, :some_symbol)
        expect(@query).to be_finished
      end
      its "should accept a callback as an argument" do
        expect { |cb|
          @query.on_error(cb.to_proc)
          @query.error!(:some_symbol)
        }.to yield_with_args(@query, :some_symbol)
        expect(@query).to be_finished
      end
      its "should accept a callback as block" do
        expect { |cb|
          @query.on_error(&cb)
          @query.error!(:some_symbol)
        }.to yield_with_args(@query, :some_symbol)
        expect(@query).to be_finished
      end
    end

    describe "#on_success" do
      its "should raise an ArgumentError if no callback is provided" do
        expect { |cb|
          @query.on_success()
        }.to raise_error(ArgumentError)
      end
      its "should not be called after timeout! is called" do
        expect { |cb|
          @query.on_success(cb.to_proc)
          @query.timeout!()
        }.to_not yield_control
        expect(@query).to be_finished
      end
      its "should be called after success! is called" do
        result = double("Result")

        expect { |cb|
          @query.on_success(cb.to_proc)
          @query.success!(result)
        }.to yield_with_args(@query, result)
        expect(@query).to be_finished
      end
      its "should not be called after error! is called" do
        expect { |cb|
          @query.on_success(cb.to_proc)
          @query.error!(:some_symbol)
        }.to_not yield_control
        expect(@query).to be_finished
      end
      its "should accept a callback as an argument" do
        result = double("Result")
        expect { |cb|
          @query.on_success(cb.to_proc)
          @query.success!(result)
        }.to yield_with_args(@query, result)
        expect(@query).to be_finished
      end
      its "should accept a callback as block" do
        result = double("Result")
        expect { |cb|
          @query.on_success(&cb)
          @query.success!(result)
        }.to yield_with_args(@query, result)
        expect(@query).to be_finished
      end
    end 

    describe "#on_timeout" do
      its "should raise an ArgumentError if no callback is provided" do
        expect { |cb|
          @query.on_timeout()
        }.to raise_error(ArgumentError)
      end
      its "should be called after timeout! is called" do
        expect { |cb|
          @query.on_timeout(cb.to_proc)
          @query.timeout!()
        }.to yield_with_args(@query)
        expect(@query).to be_finished
      end
      its "should not be called after success! is called" do
        result = double("Result")
        expect { |cb|
          @query.on_timeout(cb.to_proc)
          @query.success!(result)
        }.to_not yield_control
        expect(@query).to be_finished
      end
      its "should not be called after error! is called" do
        expect { |cb|
          @query.on_timeout(cb.to_proc)
          @query.error!(:some_symbol)
        }.to_not yield_control
        expect(@query).to be_finished
      end
      its "should accept a callback as an argument" do
        expect { |cb|
          @query.on_timeout(cb.to_proc)
          @query.timeout!()
        }.to yield_with_args(@query)
        expect(@query).to be_finished
      end
      its "should accept a callback as block" do
        expect { |cb|
          @query.on_timeout(&cb)
          @query.timeout!()
        }.to yield_with_args(@query)
        expect(@query).to be_finished
      end
    end

    describe "#always" do
      its "should raise an ArgumentError if no callback is provided" do
        expect { |cb|
          @query.always()
        }.to raise_error(ArgumentError)
      end
      its "should be called after timeout! is called" do
        expect { |cb|
          @query.always(cb.to_proc)
          @query.timeout!()
        }.to yield_with_args(@query)
        expect(@query).to be_finished
      end
      its "should be called after success! is called" do
        result = double("Result")
        expect { |cb|
          @query.always(cb.to_proc)
          @query.success!(result)
        }.to yield_with_args(@query)
        expect(@query).to be_finished
      end
      its "should be called after error! is called" do
        expect { |cb|
          @query.always(cb.to_proc)
          @query.error!(:some_symbol)
        }.to yield_with_args(@query)
        expect(@query).to be_finished
      end
      its "should accept a callback as an argument" do
        result = double("Result")
        expect { |cb|
          @query.always(cb.to_proc)
          @query.success!(result)
        }.to yield_with_args(@query)
        expect(@query).to be_finished
      end
      its "should accept a callback as block" do
        result = double("Result")
        expect { |cb|
          @query.always(&cb)
          @query.success!(result)
        }.to yield_with_args(@query)
        expect(@query).to be_finished
      end
    end
  end
end

