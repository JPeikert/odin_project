def bubble_sort(array)
  not_sorted = true
  sorted = 1

  while not_sorted
    (0 ... (array.length - sorted)).each do |index|
      if array[index] > array[index + 1]
        array[index], array[index + 1] = array[index + 1], array[index]
      end
    end

    sorted += 1
    if sorted >= array.length
      not_sorted = false
    end
  end

  puts "Your sorted array:"
  puts array.inspect, ""
end



def bubble_sort_by(array)
  not_sorted = true
  sorted = 1

  while not_sorted
    (0 ... (array.length - sorted)).each do |index|
      if yield(array[index], array[index + 1]) > 0
        array[index], array[index + 1] = array[index + 1], array[index]
      end
    end

    sorted += 1
    if sorted >= array.length
      not_sorted = false
    end
  end

  puts "Your sorted array:"
  puts array.inspect, ""
end



def interface
  exit = false

  while !exit
    user_input = ""

    puts "What do you want to do?"
    puts "-- To use bubble sort on integers write 'bubble'"
    puts "-- To use bubble sort ascending on strings' lengths write 'asc'"
    puts "-- To use bubble sort descending on strings' lengths write 'desc'"
    puts "-- To quit program write 'exit'"

    user_input = gets.chomp.downcase
    puts ""

    if user_input == "bubble"
      puts "Array to sort:"
      user_input = gets.split.map(&:to_i)
      bubble_sort(user_input)
    elsif user_input == "asc"
      puts "Array to sort:"
      user_input = gets.split(/[,\s]+/).map {|x| x}
      bubble_sort_by(user_input) { |left, right| left.length - right.length }
    elsif user_input == "desc"
      puts "Array to sort:"
      user_input = gets.split(/[,\s]+/).map {|x| x}
      bubble_sort_by(user_input) { |left, right| right.length - left.length }
    elsif user_input == "exit"
      exit = true
    else
      puts "Unknown command"
    end
    
  end

end



interface