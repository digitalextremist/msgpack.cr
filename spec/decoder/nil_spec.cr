require "../spec_helper"

describe Msgpack do
  context "Decodes nil" do
    it "decodes one Nil" do
      Msgpack.decode([0xc0_u8]).should eq(nil)
    end

    it "decodes two Nils" do
      Msgpack.decode([0xc0_u8, 0xc0_u8]).should eq([nil, nil])
    end
  end
end 
