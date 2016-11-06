require 'socket'
require 'json'



class Server


  def initialize
    @server = TCPServer.open(2000)  # Socket to listen on port 2000
  end
  

  def run
    loop do                                       # Servers run forever
      Thread.start(@server.accept) do |client|    # Wait for a client to connect and create new thread for him
        request = get_request(client)             # Read request

        client.puts(handle_request(request))      # Respond to request
        client.close                              # Disconnect from the client
      end
    end
  end




  private


## REQUESTS HANDLING

# Get request from client
  def get_request(client)
    request = ""
    while line = client.gets
      request << line
      break if request =~ /\r\n\r\n$/
    end
    body_size = request.split(" ")[-1].to_i
    if (body_size = request.split(" ")[-1].to_i) > 0
      line = client.read(body_size) 
      request << line
    end
    puts "Received request: #{request.inspect}"
    request
  end


# Handle request from client
  def handle_request(request)
    method, path, http_version = request.split(" ", 3)

    response = case method
    when "GET" then get_response(path)
    when "POST" then post_response(path, request)
    else bad_response
    end

    response
  end



## RESPONSE CREATION

# Create response for GET method
  def get_response(path)
    if File.exist?(path[1..-1])
      file = File.open(path[1..-1])
      headers = {"Date" => Time.now.ctime, "Content-Type" => "text/html", "Content-Length" => File.size(file)}
      response = create_response("200", "OK", headers, file.read)
    else
      response = create_response("404", "Not Found")
    end
    response
  end


# Create response for POST method
  def post_response(path, request)
    if File.exist?(path[1..-1])
      file = File.open(path[1..-1])
      file_content = file.read

      req_headers, req_body = request.split("\r\n\r\n", 2)
      params = JSON.parse(req_body)

      data = "<li>Name: #{params['user']['name']}</li><li>Email: #{params['user']['email']}</li>"
      file_content.gsub!("<%= yield %>", data)

      headers = {"Date" => Time.now.ctime, "Content-Type" => "text/html", "Content-Length" => file_content.size}
      response = create_response("200", "OK", headers, file_content)
    else
      response = create_response("404", "Not Found")
    end
    response
    
  end


# Create response for unknown method
  def bad_response
    create_response("400", "Requested Method Unknown")
  end


# Create response string
  def create_response(code, expl, headers = nil, body = nil)
    response_string = "HTTP/1.0 #{code} #{expl}\r\n"
    headers.each { |key, value| response_string << "#{key}: #{value}\r\n" } if headers
    response_string << "\r\n"
    response_string << body if body

    response_string
  end


end




server = Server.new
server.run