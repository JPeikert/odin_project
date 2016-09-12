class Game


  def initialize(turns = 12)
    @board = Board.new
    @runs = true
    @turns_left = turns
    @AI = AI.new
    @human_codebreaker = false 
  end



  def run
    start
    while @runs
      turn
    end
  end




  private


  def start
    started = false
    puts "Welcome to the Mastermind game."

    while !started
      puts "Options:"
      puts "1. Play as Codemaker"
      puts "2. Play as Codebreaker"
      puts "3. Instructions"

      choice = game_choice
      case choice
      when 1
        puts "Write your code (4 digits, each from 1 to 6)."
        @board.create_secret(secret_choice)
        @human_codebreaker = false
        started = true
      when 2
        puts "AI creates code..."
        @board.create_secret(@AI.create_secret)
        puts "It has 4 digits, each from 1 to 6."
        @human_codebreaker = true
        started = true
      when 3
        print_instructions
      end
    end

  end



  def turn
    if @human_codebreaker
      secret = make_guess
      feedback = @board.make_guess(secret)
      print_feedback(feedback)
    else
      secret = @AI.make_guess(@board.log, @board.secret)
      puts "AI guesses... #{secret}"
      feedback = @board.make_guess(secret)
      print_feedback(feedback)
    end
    print_logs
    @turns_left -= 1
    @runs = false if check_end_conditions
  end



  def check_end_conditions
    if @board.log.last[:feedback] == "RRRR"
      puts "Codebreaker won!"
      puts "Secret code was: #{@board.secret}"
      return true
    elsif @turns_left <= 0
      puts "Codemaker won!"
      puts "Secret code was: #{@board.secret}"
      return true
    else
      return false
    end
  end



  def make_guess
    puts "Write your guess:"
    begin
      choice = gets.chomp
      raise "Wrong length of code!" if choice.length != 4
      secret = Array.new
      choice.length.times do |i|
        raise "Code out of range!" if !choice[i].to_i.between?(1, 6)
        secret << choice[i].to_i
      end
    rescue StandardError => e
      puts "#{e} Try different code."
      retry
    else
      return secret
    end
  end



  def print_feedback(feedback)
    puts "Codemaker gives a feedback: #{feedback}."
  end



  def print_logs
    puts "\nGuesses so far:"
    @board.show_log
    print "\n\n"
  end



  def print_instructions
    puts "\nMastermind is a game for two players. One of them becomes Codemaker and secound becomes Codebreaker.
Codemaker creates a secret code consiting of 4 digits, each of them between 1 and 6.
Codebreaker's role is to guess the code. To do that he has set amount of turns (default: 12).
After each guess Codebreaker gets feedback. Each digit with proper number and spot gives 'R' in feedback
and each proper number in wrong spot gives 'W' in feedback.\n\n"
  end



  def game_choice
    begin
      choice = gets.chomp.to_i
      raise "Wrong input!" if !choice.between?(1, 3)
    rescue StandardError => e
      puts "#{e} Write either '1', '2' or '3'"
      retry
    else
      return choice
    end
  end



  def secret_choice
    begin
      choice = gets.chomp
      raise "Wrong length of code!" if choice.length != 4
      secret = Array.new
      choice.length.times do |i|
        raise "Code out of range!" if !choice[i].to_i.between?(1, 6)
        secret << choice[i].to_i
      end
    rescue StandardError => e
      puts "#{e} Try different code."
      retry
    else
      return secret
    end
  end


end





class Board


  attr_reader :log, :secret


  def initialize
    @secret = Array.new(4, 0)
    @colors = Array.new(6, 0)
    @log = Array.new
  end



  def show_log
    @log.each_with_index do |entry, index|
      puts "#{index + 1}. #{entry[:guess]}\t\t#{entry[:feedback]}"
    end
  end



  def create_secret(secret)
    begin
      raise "Wrong format!" if secret.class != Array
      raise "Wrong length of code!" if secret.length != 4
      secret.each do |num|
        raise "Wrong color!" if !num.between?(1, 6)
      end
    rescue
      puts "#{e} Try different code."
      return false
    else
      @secret = secret.dup
      @secret.each do |num|
        num -= 1
        @colors[num] += 1
      end
      return true
    end
  end



  def make_guess(guess)
    feedback = ""

    feedback = create_feedback(guess)
    
    create_log_entry(guess, feedback)
    return feedback
  end




  private


  def create_log_entry(guess, feedback)
    @log.push({guess: guess, feedback: feedback})
  end



  def create_feedback(guess)
    feedback = ""
    guessed_colors = @colors.dup
    temp_guesses = guess.dup

    temp_guesses.length.times do |i|
      if guess[i] == @secret[i] 
        feedback << "R"
        guessed_colors[temp_guesses[i] - 1] -= 1
        temp_guesses[i] = -1
      end
    end

    temp_guesses.length.times do |i|
      if temp_guesses[i] > 0
        if guessed_colors[temp_guesses[i] - 1] > 0
          feedback << "W"
          guessed_colors[temp_guesses[i] - 1] -= 1
        end
      end
    end
    feedback = feedback.chars.sort.join

    return feedback
  end


end





class AI


  def initialize
    @possible_codes = [1, 2, 3, 4, 5, 6].repeated_permutation(4).to_a
    @guesses = 0
  end



  def create_secret
    secret = Array.new
    4.times do |i|
      secret << 1 + Random.rand(6)
    end
    return secret
  end



  def make_guess(log, true_secret)
    secret = Array.new
    if @guesses == 0
      secret = [1, 1, 2, 2]
      @guesses += 1
    else
      analyze_log(log)
      secret = @possible_codes.sample
    end

    return secret
  end




  private


  def analyze_log(log)
    reduce_possible_codes(log)
  end



  def reduce_possible_codes(log)
    last_guess = log.last[:guess]
    last_feedback = log.last[:feedback]
    colors = Array.new(6, 0)
    last_guess.each do |num|
      num -= 1
      colors[num] += 1
    end

    @possible_codes.each do |guess|
      feed = reduce_feedback(last_guess, guess, colors)
      @possible_codes.delete(guess) unless last_feedback == feed
    end
  end



  def reduce_feedback(temp_secret, guess, colors)
    guessed_colors = colors.dup
    feedback = ""
    temp_guesses = guess.dup

    temp_guesses.length.times do |i|
      if guess[i] == temp_secret[i] 
        feedback << "R"
        guessed_colors[temp_guesses[i] - 1] -= 1
        temp_guesses[i] = -1
      end
    end

    temp_guesses.length.times do |i|
      if temp_guesses[i] > 0
        if guessed_colors[temp_guesses[i] - 1] > 0
          feedback << "W"
          guessed_colors[temp_guesses[i] - 1] -= 1
        end
      end
    end
    feedback = feedback.chars.sort.join

    return feedback
  end


end






game = Game.new
game.run