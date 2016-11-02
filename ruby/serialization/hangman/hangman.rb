require 'json'

class Hangman 

  def initialize
    @secret = prepare_secret.scan(/\w/)
    @guesses_left = 7
    @misses = []
    @guessed = Array.new(@secret.size, "_")
  end


  def start
    @runs = true
    puts "Welcome to Hangman The Game."
    puts "Do you want to:\n" +
        "1. Start a new game?\n" +
        "2. Continue a game?"

    check_choice
  end




  private


  def prepare_secret
    File.readlines("5desk.txt").select { |word| word.chop.length >= 5 && word.chop.length <= 12 }.sample
  end


  def check_choice
    begin
      choice = gets.chomp.downcase
      unless (1..2) === choice.to_i
        raise "Wrong input!"
      end
    rescue StandardError => e
      puts "#{e} Write either '1' or '2'"
      retry
    else
      run if choice == "1"
      ask_load if choice == "2"
    end
  end


  def continue(sec, gleft, miss, g, r)
    puts sec
    @secret = sec
    @guesses_left = gleft
    @misses = miss
    @guessed = g
    @runs = r

    puts "Loaded successfully"
    run
  end


  def run
    while @runs
      turn
    end
  end


  def turn
    draw_state
    get_new_guess
  end


  def draw_state
    puts "\e[H\e[2J"
    puts "Word:  #{@guessed.join(" ")}"
    puts "Misses:  #{@misses.join(", ")}"
    puts "Guesses left: #{@guesses_left}"
  end


  def get_new_guess
    puts "You can /save/ a game"
    puts "Guess:"
    guess = check_guess
    process_guess(guess)
  end


  def check_guess
    begin
      guess = gets.chomp.downcase
      if guess != "save" && (guess.length != 1 || guess =~ /[^[:alpha:]]/)
        raise "Wrong input!"
      end
    rescue StandardError => e
      puts "#{e} Write one letter or 'save'"
      retry
    else
      guess
    end
  end


  def process_guess(guess)
    if guess == "save"
      ask_save
    else
      correct_guess = false

      @secret.each_with_index do |c, index|
        if c == guess
          correct_guess = true
          @guessed[index] = c
        end
      end

      unless correct_guess
        @misses << guess
        @guesses_left -= 1
      end

      check_end_conditions
    end
  end


  def check_end_conditions
    win if @guessed.select { |c| c =~ /_/ }.count == 0
    lose if @guesses_left <= 0
  end


  def win
    draw_state
    puts "Congratulations, you won!"
    @runs = false
  end


  def lose
    draw_state
    puts "Sorry, you are out of guesses.\n" +
        "You lost!\n" +
        "Correct word: #{@secret.join}"
    @runs = false
  end


  def ask_save
    puts "Save name:"

    begin
      filename = gets.chomp.downcase
      unless filename =~ /[[:alnum:]]/
        raise "Wrong input!"
      end
    rescue StandardError => e
      puts "#{e} Save name can be only alphanumerical"
      retry
    else
      save(filename)
    end
  end


  def ask_load
    if Dir["saves/*"].size == 0
      puts "No games saved! Starting a new game..."
      run
    else
      puts "Which save do you want to load?"
      saves = Dir["saves/*"]

      begin
        saves.each_with_index { |file, index| puts "#{index + 1}. #{file[6..-1]}" }

        file_to_load = gets.chomp.downcase

        unless (1..saves.size) === file_to_load.to_i
          raise "Wrong input!"
        end
      rescue StandardError => e
        puts "#{e} Write number corresponding to a file"
        retry
      else
        load(saves[file_to_load.to_i - 1])
      end
    end
  end


  def save(filename)
    Dir.mkdir("saves") unless Dir.exist?("saves")

    filename = "saves/" + filename
    File.open(filename, 'w') { |file| file.puts to_json }
  end


  def load(filename)
    puts "Loading..."
    puts File.read(filename).inspect
    from_json(File.read(filename))
  end


  def to_json
    JSON.dump ({
      :secret => @secret,
      :guesses_left => @guesses_left,
      :misses => @misses,
      :guessed => @guessed,
      :runs => @runs
    })
  end

  def from_json(string)
    data = JSON.load string
    continue(data['secret'], data['guesses_left'], data['misses'], data['guessed'], data['runs'])
  end

end




hangman = Hangman.new

hangman.start