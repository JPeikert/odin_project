require 'sinatra'
require 'sinatra/reloader'

set :secret_number, rand(100)
set :answer, 2

@@guesses_left = 5

def check_guess(guess)
  difference = guess.to_i - settings.secret_number
  if difference > 5
    settings.answer = 2
    msg = "Way too high!"
  elsif difference > 0
    settings.answer = 1
    msg = "Too high!"
  elsif difference < -5
    settings.answer = 2
    msg = "Way too low!"
  elsif difference < 0
    settings.answer = 1
    msg = "Too low!"
  else
    settings.answer = 0
    msg = "Correct!\nCreating a new number..."
  end
  @@guesses_left -= 1
  if settings.answer > 0 && @@guesses_left <= 0
    @@guesses_left = 5
    msg = "You didn't guess a correct number!\nCreating a new number..."
    settings.secret_number = rand(100)
  end
  msg
end

get '/' do
  if params[:cheat]
    cheat = params[:cheat] == "true" ? true : false
  end
  if params[:guess]
    guess = params[:guess]
    message = check_guess(guess)
  end
  erb :index, :locals => {:secret_number => settings.secret_number, :message => message, :result => settings.answer, :cheat => cheat}
end

post '/' do

end