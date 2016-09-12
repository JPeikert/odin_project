WIN_SEQ = [[[0, 0], [0, 1], [0, 2]], [[1, 0], [1, 1], [1, 2]], [[2, 0], [2, 1], [2, 2]],
           [[0, 0], [1, 0], [2, 0]], [[0, 1], [1, 1], [2, 1]], [[0, 2], [1, 2], [2, 2]],
           [[0, 0], [1, 1], [2, 2]], [[2, 0], [1, 1], [0, 2]]]

# This class is responsible for running a game.
class Game


  # Create the game object, board object and store board, turn counter and running flag.
  def initialize
    @board = Board.new
    @runs = true
    @turn = 0
  end

  # Run the game
  def run
    start
    @board.draw
    while @runs
      turn
      @turn += 1
    end
  end




  private

  # Start the game, choose human/AI players, give names to human players.
  def start
    @runs = true
    puts "Welcome to the Tic Tac Toe game."

    puts "Player1: 'human' or 'AI'?"
    human = human_check
    if human
      puts "Name of Player1:"
      name = name_check
      set_player(name, human, true)
    else
      set_player("AI1", human, true)
    end

    puts "Player 2: 'human' or 'AI'?"
    human = human_check
    if human
      puts "Name of Player2:"
      name = name_check
      set_player(name, human, false)
    else
      set_player("AI2", human, false)
    end

    shuffle_players
  end


  # Logic for each turn.
  def turn
    player = @turn % 2 == 0 ? @player1 : @player2
 
    puts "#{player.name}'s turn"
    move = player.make_move(@board)
    puts "#{player.name} moves to #{move.upcase}"

    @board.draw
    check_win_conditions(player)
    check_draw_conditions
  end


  # Check response to human/AI choice.
  def human_check
    begin
      human = gets.chomp.downcase
      if human != "human" && human != "ai"
        raise "Wrong input!"
      end
    rescue StandardError => e
      puts "#{e} Write either 'human' or 'AI'"
      retry
    else
      return human == 'human' ? true : false
    end
  end


  # Check response to name choice.
  def name_check
    begin
      name = gets.chomp
    rescue StandardError => e
      puts "#{e} Try again!"
      retry
    else
      return name
    end
  end


  # Create player.
  def set_player(player, human, first)
    if first
      @player1 = human ? Player.new(player) : AI.new(player)
    else
      @player2 = human ? Player.new(player) : AI.new(player)
    end
  end


  # Order players.
  def shuffle_players
    shuffled = [@player1, @player2].shuffle
    @player1 = shuffled[0]
    @player1.number = 1
    @player2 = shuffled[1]
    @player2.number = 2

    puts "#{@player1.name} starts as Player 1"
    puts "#{@player2.name} starts as Player 2"
  end


  # Check conditions for winning a game. End the game if they are met.
  def check_win_conditions(player)
    if @board.check_win(player.number)
      puts "#{player.name} (player #{player.number}) won!"
      @runs = false
    end
  end


  # Check condition for draw.
  def check_draw_conditions
    if @board.possible_moves.empty?
      puts "Draw! Nobody wins."
      @runs = false
    end
  end


end




# This class is responsible for handling a board.
class Board


  attr_reader :board


  # Create the board object, store array of its fields.
  def initialize
    @board = Array.new(3){Array.new(3)} 
  end


  # Draw a current board.
  def draw
    puts "\e[H\e[2J"
    @board.each_with_index do |row, row_index|
      print "   1   2   3 \n\n" if row_index == 0
      row.each_with_index do |field, field_index|
        if field_index == 0
          print translate_row(row_index, true), " "
        end
        print case field
        when 1
          " X"
        when 2
          " O"
        else
          "  "
        end
        print " |" unless field_index == 2
      end
      puts "\n  ---+---+---" unless row_index == 2
    end
    print "\n\n"
  end


  # Return a list of possible moves.
  def possible_moves
    moves = Array.new
    @board.each_with_index do |row, row_index|
      row.each_with_index do |field, field_index|
        moves.push(field_name(row_index, field_index)) if field == nil
      end
    end
    return moves
  end


  # Make a move for a player.
  def make_move(player, field)
    if possible_moves.include?(field)
      row_index, field_index = translate_field(field)
      @board[row_index][field_index] = player
    else
      puts "Non-viable move! Lost turn due to cheating."
    end
  end


  # Return a board state (for AI).
  def get_board_state
    return @board
  end


  # Check conditions for winning a game.
  def check_win(player_number, board = @board)
    WIN_SEQ.any? do |seq|
      seq.all? { |a, b| board[a][b] == player_number}
    end
  end


  # Translate literal form of field to row and field numbers (e.g. A1 = 0, 0).
  def translate_field(field)
    field = field.split(//)
    field[0] = translate_row(field[0], false)
    field[1] = field[1].to_i - 1
    return field[0], field[1]
  end




  private

  # Translate row number to literal form.
  def translate_row(row, to_letter)
    alphabet = ('A'..'Z').to_a
    return to_letter ? alphabet[row] : alphabet.index(row)
  end
  

  # Return literal form of field from its row and field indexes.
  def field_name(row_index, field_index)
    field_index += 1
    return "#{translate_row(row_index, true)}#{field_index}"
  end


end




# This class 
class Player


  attr_reader :name
  attr_accessor :number


  # Create the player object, store its name.
  def initialize(name)
    @name = name
  end



  def make_move(board)
    puts "What move do you want to make?"
    puts "List of possible moves:"
    puts board.possible_moves.inspect

    move = check_move(board)

    board.make_move(@number, move)

    return move
  end




  private


  def check_move(board)
    begin
      move = gets.chomp.upcase
      if !board.possible_moves.include?(move)
        raise "Non-viable move."
      end
    rescue StandardError => e
      puts "#{e} Try again."
      retry
    else
      return move
    end
  end


end





class AI < Player


  # Return best move for AI player.
  def make_move(board)
    best_move = calculate_best_move(board)
    board.make_move(@number, best_move.to_s)

    return best_move
  end




  private


  # Calculate values of each possible move. Return best move.
  def calculate_best_move(board)
    move_values = { A1: 0, A2: 0, A3: 0,
                    B1: 0, B2: 0, B3: 0,
                    C1: 0, C2: 0, C3: 0 }

    move_values.each do |field, value|
      if board.possible_moves.include?(field.to_s)
        row_index, field_index = board.translate_field(field.to_s)
        move_values[field] = calculate_move_value(row_index, field_index, board)
      end
    end

    return move_values.max_by{ |k, v| v }[0]
  end


  # Calculate value of one possible move.
  def calculate_move_value(row_index, field_index, board)
    return 100 if check_end(true, row_index, field_index, board)
    return 99 if check_end(false, row_index, field_index, board)
    return rand(99)

  end


  # Check conditions for a move, that wins a game or saves from losing it.
  def check_end(for_win, row_index, field_index, board)
    board_state = board.get_board_state
    new_board_state = Marshal.load(Marshal.dump(board_state))
    new_board_state[row_index][field_index] = @number

    if for_win
      new_board_state[row_index][field_index] = @number
      return board.check_win(@number, new_board_state)
    else
      new_board_state[row_index][field_index] = @number % 2 + 1
      return board.check_win((@number % 2 + 1), new_board_state)
    end
  end


end





game = Game.new
game.run