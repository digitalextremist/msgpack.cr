class Array(T)
  def to_slice : Slice(T)
    Slice(T).new(to_unsafe, size)
  end
end
