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

    describe "#finished?" do
      it "should be false by default" do
        expect(@query.finished?).to be_false
      end
      it "should be true after #cancel! is called" do
        @query.cancel!
        expect(@query.finished?).to be_true
      end
      it "should be true after #error! is called" do
        @query.error!(1234)
        expect(@query.finished?).to be_true
      end
      it "should be true after #success! is called" do
        result = double("Result")
        @query.success!(result)
        expect(@query.finished?).to be_true
      end
    end

    describe "#start!" do
      it "should set the async_id" do
        expect(@query.async_id).to be_nil
        @query.start!(1234)
        expect(@query.async_id).to eq(1234)
      end

      specify "the query should be started after calling" do
        @query.start!(1234)
        expect(@query).to be_started
      end
    end

    describe "#started?" do
      it "should be false by default" do
        expect(@query.started?).to be_false
      end
      it "should be true after start! is called" do
        @query.start!(1234)
        expect(@query.started?).to be_true
      end
    end

    describe "#on_start" do
      it "should be called after start! is called" do
        expect { |cb|
          @query.on_start(cb.to_proc)
          @query.start!(1234)
        }.to yield_with_args(@query)
      end
    end

    describe "#error!" do
      it "should require an error code as an argument" do
        expect {
          @query.error!
        }.to raise_error(ArgumentError)
        expect {
          @query.error!(1234)
        }.to_not raise_error
      end

      specify "the query finished after being called" do
        @query.error!(1234)
        expect(@query).to be_finished
      end
    end

    describe "#success!" do
      it "should require a result as an argument" do
        expect {
          @query.success!
        }.to raise_error(ArgumentError)
        result = double("Result")
        expect {
          @query.success!(result)
        }.to_not raise_error
      end

      specify "the query finished after being called" do
        result = double("Result")
        @query.success!(result)
        expect(@query).to be_finished
      end
    end

    describe "#cancel!" do
      it "should require that no arguments be specified" do
        expect {
          @query.cancel!(1234)
        }.to raise_error(ArgumentError)
        expect {
          @query.cancel!()
        }.to_not raise_error
      end

      specify "the query finished after being called" do
        @query.cancel!
        expect(@query).to be_finished
      end
    end


    describe "#on_error" do
      specify "callbacks should be called upon #error!, but not others" do
        expect { |success_cb|
          expect { |error_cb|
            expect { |cancel_cb|
              @query.on_success(&success_cb)
              @query.on_error(&error_cb)
              @query.on_cancel(&cancel_cb)
              @query.error!(999)
            }.to_not yield_control
          }.to yield_control
        }.to_not yield_control
      end

      specify "callbacks should be called with the query object and error code" do
        expect { |error_cb|
          @query.on_error(&error_cb)
          @query.error!(999)
        }.to yield_with_args(@query, 999)
      end
    end

    describe "#on_success" do
      specify "callbacks should be called upon #success!, but not others" do
        result = double("Result")
        expect { |success_cb|
          expect { |error_cb|
            expect { |cancel_cb|
              @query.on_success(&success_cb)
              @query.on_error(&error_cb)
              @query.on_cancel(&cancel_cb)
              @query.success!(result)
            }.to_not yield_control
          }.to_not yield_control
        }.to yield_control
      end

      specify "callbacks should be called with the query object and result object" do
        result = double("Result")
        expect { |success_cb|
          @query.on_success(&success_cb)
          @query.success!(result)
        }.to yield_with_args(@query, result)
      end
    end 

    describe "#on_cancel" do
      specify "callbacks should be called upon #cancel!, but not others" do
        expect { |success_cb|
          expect { |error_cb|
            expect { |cancel_cb|
              @query.on_success(&success_cb)
              @query.on_error(&error_cb)
              @query.on_cancel(&cancel_cb)
              @query.cancel!()
            }.to yield_control
          }.to_not yield_control
        }.to_not yield_control
      end

      specify "callbacks should be called with the query object" do
        expect { |cancel_cb|
          @query.on_cancel(&cancel_cb)
          @query.cancel!()
        }.to yield_with_args(@query)
      end
    end

    describe "#on_finish" do
      it "should be called after cancel! is called" do
        expect { |cb|
          @query.on_finish(cb.to_proc)
          @query.cancel!()
        }.to yield_with_args(@query)
      end
      it "should be called after success! is called" do
        result = double("Result")
        expect { |cb|
          @query.on_finish(cb.to_proc)
          @query.success!(result)
        }.to yield_with_args(@query)
      end
      it "should be called after error! is called" do
        expect { |cb|
          @query.on_finish(cb.to_proc)
          @query.error!(999)
        }.to yield_with_args(@query)
      end
    end
  end
end

