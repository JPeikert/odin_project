require 'sinatra'
require 'sinatra/reloader' if development?

set :cipher, ""

def caesar_cipher(phrase, shift)
  cipher = ""
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
  cipher
end



get '/' do
  erb :index, :locals => {:cipher => settings.cipher}
end

post '/cipher' do
  if params[:msg]
    msg = params[:msg]
    shift = params[:shift]
    settings.cipher = caesar_cipher(msg, shift.to_i)
  end
  redirect to('/')
end