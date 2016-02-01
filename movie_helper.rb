module Helper
  #read data into nested array of tuples
  def read filename
    data = Array.new(Array.new())
    open(filename).read.split("\n").each do |line|
      data.push line.split("\t").map{ |e| e.to_i }.first(3)
    end
    return data
  end

  def diff r1, r2
    return (r1 - r2).abs
  end
end

class Hash
  #if Hash already contains key, merge the new inner hash with hash key already mapped to
  #allows smooth transition from data to hashmaps
  def nest_store key, inner_hash
    if self.include? key
      self[key].merge!(inner_hash)
    else
      self.store(key, inner_hash)
    end
  end

  #average all values in this hash
  def val_avg
    (self.values.sum.to_f / self.length).round(1)
  end
end

class Array
  #average all values in array
  def mean
    return (self.sum.to_f / self.size)
  end

  #returns middle element in odd-length array; first element in top half of even-length array
  def median_ish
    sorted = self.sort
    len = sorted.length
    return self[len / 2]
  end

  def sum
    sum = 0
    self.each { |e| sum += e }
    return sum
  end
end
