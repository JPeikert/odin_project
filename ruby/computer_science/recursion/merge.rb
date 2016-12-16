def merge_sort(arr)
  return arr if arr.length <= 1

  left = arr[0..(arr.length/2)-1]
  right = arr[arr.length/2..-1]

  left = merge_sort(left)
  right = merge_sort(right)

  merge(left, right)
end



def merge(left, right)
  result = []

  while left.size > 0 && right.size > 0
    result << (left[0] < right[0] ? left.shift : right.shift)
  end

  result.push(*left) if left.size > 0
  result.push(*right) if right.size > 0

  result
end



array_to_sort = [0, 2, 91, -11, -1, 0, 0, 1, 6, -17, 24, 1, -1, -83, 10, -90]

puts merge_sort(array_to_sort).inspect