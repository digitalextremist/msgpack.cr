module Msgpack
  class Ext
    property! type : Int8
    property! data : Bytes

    def initialize
      yield(self)
    end

    def reserved_type?
      type < 0
    end

    def custom_type?
      !reserved_type?
    end
  end  
end
