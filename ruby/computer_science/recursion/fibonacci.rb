def fib(n, result = [0, 1])
  (n-1).times { |x| result << result[-1] + result[-2] }
  n > 0 ? result : [0]
end

def fib_rec(n, result = [0, 1])
  return [0] if n == 0
  return result if n == 1
  fib_rec(n-1, result << result[-1] + result [-2])
end

puts fib(20).inspect

puts fib_rec(20).inspect