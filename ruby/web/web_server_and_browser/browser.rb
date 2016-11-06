require 'socket'
require 'json'



class Browser
  

  def initialize
    @host = "localhost"
    @port = 2000
    @path = "/index.html"
    @users = Hash.new
  end


  def run
    print "You will be connected to #{@host} on port #{@port}. Do you want to connect to this server? (y/n): "
    server_choice_check

    @runs = true
    while @runs
      display_options
      request_choice(choice_check)
    end
  end




  private


# Change default server
  def connect_to_new_server
    print "Please, write address of a server you wish to connect: "
    host_check
    print "Please, write port (default: 80): "
    port_check
  end


# Display options for user
  def display_options
    puts "Please, write a type of request you want to send: GET or POST."
    puts "Write EXIT to exit."
  end



## METHOD (GET/POST) CHOICE AND LOGIC

# Handle user choice
  def request_choice(choice)
    case choice
    when "GET" then get_choice
    when "POST" then post_choice
    when "EXIT" then @runs = false
    end
  end


# Handle GET method
  def get_choice
    path_check("/index.html")

    request = make_request(:get)

    get_response(request)
  end


# Handle POST method
  def post_choice
    path_check("/thanks.html")
    body = gather_input.to_json
    headers = {"Date" => Time.now.ctime, "Content-Type" => "application/x-www-form-urlencoded", "Content-Length" => body.length}

    request = make_request(:post, headers, body)

    get_response(request)
  end


# Get response from server and print it
  def get_response(request)
    socket = TCPSocket.open(@host, @port)
    socket.print(request)
    response = socket.read
    
    headers, body = response.split("\r\n\r\n", 2)
    response_code, response_message = headers.split("\r\n")[0].split(" ")[1], headers.split("\r\n")[0].split(" ")[2..-1].join(" ")
    if response_code =~ /^2\d\d/
      print body                          # And display it
    else
      puts "#{response_code} #{response_message}"
    end
  end


# Create name-email hash for POST
  def gather_input
    name = name_check
    email = email_check

    {user: {name: name, email: email}}
  end



## REQUEST CREATION

# Create request to server
  def make_request(type, headers = nil, body = nil)
    request = "#{type.to_s.upcase} #{@path} HTTP/1.0\r\n"
    request << add_headers(headers) if headers
    request << "\r\n"
    request << body if body
    request
  end


# Add headers to request
  def add_headers(headers)
    headers_string = ""

    headers.each do |key, value|
      headers_string << "#{key}: #{value}\r\n"
    end

    headers_string
  end



## INPUT VALIDATION

# Validate server_choice
  def server_choice_check
    begin
      choice = gets.chop.downcase
      if choice != "y" && choice != "n"
        raise "Wrong input!"
      end
    rescue StandardError => e
      puts "#{e} Write either 'y' or 'n'"
      retry
    else
      connect_to_new_server if choice == "n"
    end
  end


# Validate host
  def host_check
    begin
      new_host = gets.chop.downcase
      unless new_host =~ /^(([[:alnum:]]|[[:alnum:]][[:alnum:]\-]*[[:alnum:]])\.)*([[:alnum:]]|[[:alnum:]][[:alnum:]\-]*[[:alnum:]])$/ ||
        new_host =~ /^((\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.){3}(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])$/
        raise "Wrong input!"
      end
    rescue StandardError => e
      puts "#{e} Write proper address"
      retry
    else
      @host = new_host
    end
  end


# Validate port
  def port_check
    begin
      new_port = gets.chop.downcase
      unless new_port.to_i.between?(0, 65536) || new_port == ""
        raise "Wrong input!"
      end
    rescue StandardError => e
      puts "#{e} Ports can be only in range from 0 to 65536!"
      retry
    else
      if new_port == ""
        @port = 80
      else
        @port = new_port
      end
    end
  end


# Validate choice and run method
  def choice_check
    begin
      choice = gets.chop.upcase
      if choice != "GET" && choice != "POST" && choice != "EXIT"
        raise "Wrong input!"
      end
    rescue StandardError => e
      puts "#{e} You can choose between GET, POST and EXIT"
      retry
    else
      choice
    end      
  end


# Validate path
  def path_check(default_path)
    print "Please, write path to a requested resource: "
    begin
      new_path = gets.chop.downcase
      unless new_path =~ /\/(\w|\w[\w\-]*\w)+\.\w+/ || new_path == ""
        raise "Wrong input!"
      end
    rescue StandardError => e
      puts "#{e} Write proper path!"
      retry
    else
      if new_path == ""
        @path = default_path
      else
        @path = new_path  
      end
    end
  end


# Validate name
  def name_check
    print "Write name: "
    begin
      name = gets.chop
      unless name =~ /^(\w+\s*)+\w+$/
        raise "Wrong input!"
      end
    rescue StandardError => e
      puts "#{e} Write proper name"
      retry
    else
      name
    end
  end


# Validate email
  def email_check
    print "Write email: "
    begin
      email = gets.chop.downcase
      unless email =~ /^\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+$/
        raise "Wrong input!"
      end
    rescue StandardError => e
      puts "#{e} Write proper email"
      retry
    else
      email
    end
  end


end




browser = Browser.new
browser.run