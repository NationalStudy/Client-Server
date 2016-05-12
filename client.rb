require "socket" # Socket library
class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end

  def send
    @request = Thread.new do
      puts "Enter your name:"
      loop {
        msg = $stdin.gets.chomp
        close_connection if msg == 'exit'
        @server.puts( msg )
      }
    end
  end

  def listen
    @response = Thread.new do
      loop do
        msg = @server.gets.chomp
        puts "\e[#{34}m#{msg}\e[0m"
      end
    end
  end

  private

    def close_connection
      @server.puts('exit')
      @server.close
      puts "Good bay!"
      exit
    end
end

server = TCPSocket.new( "localhost", 3000 )
Client.new( server )
