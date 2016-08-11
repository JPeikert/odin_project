module Enumerable


  def my_each
    for i in self
      yield(i) if block_given?
    end
    self
  end



  def my_each_with_index
    for i in 0...self.size
      yield(self[i], i) if block_given?
    end
    self
  end



  def my_select
    return self unless block_given?
    result = Array.new

    self.my_each { |x| result << x if yield(x) }
        
    result
  end



  def my_all?
    if block_given?
      self.my_each { |x| return false unless yield(x) }
      return true
    else
      self.my_each { |x| return false unless x }
      return true
    end
  end



  def my_any?
    if block_given?
      self.my_each { |x| return true if yield(x) }
      return false
    else
      self.my_each { |x| return true if x }
      return false
    end
  end



  def my_none?
    if block_given?
      self.my_each { |x| return false if yield(x) }
      return true
    else
      self.my_each { |x| return false if x }
      return true
    end
  end



  def my_count(arg = nil)
    counter = 0

    if block_given?
      self.my_each { |x| counter += 1 if yield(x) }
    elsif arg
      self.my_each { |x| counter += 1 if x == arg }
    else
      counter = self.size
    end
    counter
  end



  def my_map(&proc)
    return self unless block_given?

    result = Array.new
    self.my_each { |x| result << proc.call(x) }
    result
  end



#if both proc (as variable, not block! => array.my_map2(my_proc) instead of array.my_map2(&my_proc))
#and block is given this method will use proc instead of throwing error
  def my_map2(proc = nil)
    result = Array.new
    if proc.is_a?(Proc)
      self.my_each { |x| result << proc.call(x) }
      return result
    elsif block_given?
      self.my_each { |x| result << yield(x) }
      return result
    else
      return self
    end
  end



  def my_inject(initial = nil)
    result = initial == nil ? self.first : initial
    self.my_each_with_index do |x, index|
      if initial == nil && index == 0
        next
      else
        result = yield(result, x)
      end
    end
    result
  end


end




def multiply_els(array)
  return array.my_inject {|prod, num| prod = prod * num}
end