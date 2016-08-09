def substrings(string, dictionary)
  matches = Hash.new(0)
  string.downcase!

  dictionary.each do |word|
    string.scan(word.downcase) do |match|
      matches[match] += 1
    end
  end

  matches.each do |key, value|
    print "#{value} - #{key}\n"
  end
end



puts "Your dictionary:"
dictionary = gets.split(/[,\s]+/).map {|x| x}
puts "Your string:"
string = gets.chomp
puts "Your dictionary: #{dictionary}"
puts "Your string: #{string}"

substrings(string, dictionary)