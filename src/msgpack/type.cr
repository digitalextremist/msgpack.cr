module Msgpack
  alias Type = Nil | Bool |
    UInt8 | UInt16 | UInt32 | UInt64 |
    Int8 | Int16 | Int32 | Int64 |
    Float32 | Float64 |
    Ext | String | Bytes | Array(Type) | Hash(Type, Type)  
end
