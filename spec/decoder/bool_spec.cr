require "../spec_helper"

describe Msgpack do
  describe Bool do
    context false do
      it "Decodes one false" do
        Msgpack.decode([0b1100_0010_u8]).should eq(false)
      end

      it "Decode two falses" do
        Msgpack.decode([0b1100_0010_u8, 0b1100_0010_u8]).should eq([false, false])
      end
    end

    context true do
      it "Decodes one true" do
        Msgpack.decode([0b1100_0011_u8]).should eq(true)
      end

      it "Decode two trues" do
        Msgpack.decode([0b1100_0011_u8, 0b1100_0011_u8]).should eq([true, true])
      end
    end
  end
end
