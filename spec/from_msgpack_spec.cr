require "./spec_helper"

describe IO do
  context "#from_msgpack" do
    it "works" do
      i = MemoryIO.new
      x = [6_u8,7_u16,8_u32,9_u64,"this works",{"a" => 1_i64, "b" => 3.0, "c" => 4_i32, "d" => 5_i16, "e" => 6_i8, "f" => [] of Nil},true,false,nil]
      x.to_msgpack(i)
      i.rewind
      i.from_msgpack.should eq(x)
    end
  end
end
