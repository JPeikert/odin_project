def stock_picker(stocks)
  max_profit, min_day, max_day, min, max = 0, 0, 0, 0, 0
  i = 0

  while i < stocks.size do
    j = i + 1
      while j < stocks.size do
        if stocks[j] - stocks[i] > max_profit
          min = stocks[i]
          max = stocks[j]
          min_day = i
          max_day = j
          max_profit = stocks[j] - stocks[i]
        end 
        j += 1
      end
      i += 1
  end

  puts "Max possible profit was $#{max_profit} per share, if you bought shares day #{min_day} for $#{min} and sold them day #{max_day} for $#{max}"
end


#This method saves all local min-maxes and loops only once through stocks array
def stock_picker2(stocks)
  max_profit, min, min_day, max, max_day = 0, 0, 0 , 0, 0
  min_array, min_day_array, max_array, max_day_array = Array.new, Array.new, Array.new, Array.new
  min_array[0] = stocks[0]
  max_array[0], min_day_array[0], max_day_array[0] = 0, 0, 0
  cur_length = 0

  stocks.each_with_index do |stock, index|
    if stock > max_array[cur_length]
      max_array[cur_length] = stock
      max_day_array[cur_length] = index
    elsif stock < min_array[cur_length]
      min_array.push(stock)
      max_array.push(0)
      cur_length += 1
      min_day_array[cur_length] = index
    end
  end

  max_array.each_with_index do |m, index|
   profit = m - min_array[index]
    if profit > max_profit
      max_profit = profit
      min = min_array[index]
      max = m
      min_day = min_day_array[index]
      max_day = max_day_array[index]
    end
  end

  puts "Max possible profit was $#{max_profit} per share, if you bought shares day #{min_day} for $#{min} and sold them day #{max_day} for $#{max}."
end

puts "Stock prices:"
stock_array = gets.split.map {|x| x.to_i}

stock_picker(stock_array)