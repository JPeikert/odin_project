require 'jumpstart_auth'
require 'bitly'

Bitly.use_api_version_3

class MicroBlogger

  attr_reader :client


  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
    @bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
  end


  def run
    puts "Welcome to the MicroBlogger Twitter Client!"

    command = ""

    while command != "q"
      print "enter command: "
      input = gets.chomp
      parts = input.split
      command = parts[0]
      case command
      when "q" then puts "Goodbye!"
      when "t" then tweet(parts[1..-1].join(" "))
      when "dm" then dm(parts[1], parts[2..-1].join(" "))
      when "spam" then spam_my_followers(parts[1..-1].join(" "))
      when "elt" then everyone_last_tweet
      when "s" then shorten(parts[1])
      when "turl" then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
      else
        puts "Sorry, I don't know how to #{command}"
      end
    end
  end




  private


  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Message too long (max 140 characters)"
      return false
    end
  end


  def dm(target, message)
    puts "Trying to send to #{target} this direct message:"
    puts message
    if @client.followers.collect { |follower| @client.user(follower).screen_name }.include?(target)
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "You can send direct messages only to people who follow you!"
    end
  end


  def spam_my_followers(message)
    followers = followers_list
    followers.each { |follower| dm(follower, message) }
  end


  def everyone_last_tweet
    friends = @client.friends
    friends.sort_by { |friend| @client.user(friend).screen_name.downcase }
    friends.each do |friend|
      timestamp = @client.user(friend).status.created_at
      puts "#{@client.user(friend).screen_name} said this on #{timestamp.strftime("%A, %b %d")}..."
      puts "#{@client.user(friend).status.text}"
      puts ""
    end
  end


  def followers_list
    @client.followers.collect { |follower| @client.user(follower).screen_name }
  end


  def shorten(original_url)
    short_url = @bitly.shorten(original_url).short_url

    puts "Shortening this URL: #{original_url}"
    puts short_url
    short_url
  end


end




blogger = MicroBlogger.new
blogger.run