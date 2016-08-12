module Msgpack
  class Extension
    property! type : Int8
    property! data : Bytes

    def initialize(@type : Int8, @data : Bytes)
    end

    def reserved_type?
      type < 0
    end

    def custom_type?
      !reserved_type?
    end
  end
end
