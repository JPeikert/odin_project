def caesar_cipher(phrase, shift)
  cipher = String.new
  phrase.each_char do |x|
    x = x.ord
    if x.between?(97, 122) || x.between?(65, 90)
      x += (shift % 26)
      if x > 122 || (x > 90 && x < 97)
        x -= 26
      end
    end
    x = x.chr
    cipher += x
  end
  puts cipher
end

puts "Input string:"
string = gets.chomp

puts "Shift factor:"
shift = gets.chomp.to_i

puts "Caesar Cipher:"
caesar_cipher(string, shift)
