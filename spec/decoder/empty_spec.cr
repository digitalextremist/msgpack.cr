require "../spec_helper"

describe Msgpack do
  context "(empty)" do
    it "Decodes" do
      Msgpack.decode([] of UInt8).should eq([] of Msgpack::Type)
    end
  end
end
