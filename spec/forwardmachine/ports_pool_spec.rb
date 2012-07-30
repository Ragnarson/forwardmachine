require 'spec_helper'

describe ForwardMachine::PortsPool do
  let(:pool) { ForwardMachine::PortsPool.new(100..105) }

  describe "#reserve" do
    it "should reserve port from a pool" do
      pool.reserve.should == 100
      pool.reserve.should == 101
    end
  end

  describe "#release" do
    it "should return given port back to the pool" do
      pool.reserve
      pool.reserve
      pool.release(100)
      pool.reserve.should == 100
    end
  end
end
