require "../spec_helper"

describe Msgpack do
  context "(empty)" do
    it "Decodes" do
      x = [] of UInt8
      x.to_msgpack.from_msgpack.should eq(x)
    end
  end
end
