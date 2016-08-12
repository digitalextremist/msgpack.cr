require "../spec_helper"

describe Msgpack do
  context "Decodes nil" do
    it "decodes one Nil" do
      ([0xc0_u8].from_msgpack).should eq(nil)
    end

    it "decodes two Nils" do
      ([0xc0_u8, 0xc0_u8].from_msgpack).should eq([nil, nil])
    end
  end
end 
