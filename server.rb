require "socket" # Socket library
class Server
  def initialize( server )
    @server = server
    @connections = Hash.new
    @clients = Hash.new
    @connections[:clients] = @clients
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        begin
          flag = false
          user_name = client.gets.chomp
          @connections[:clients].each do |other_name, other_client|
            if user_name == other_name || client == other_client
              client.puts "\e[#{31}mThis name is already in use! Please choose different name!\e[0m"
              flag = true
            end
          end
        end while flag
        @connections[:clients][user_name] = client
        puts "\e[#{32}m#{user_name} joined!\e[0m"
        client.puts "\e[#{32}m Connected!\e[0m"
        client.puts "\e[#{32}m Online: #{@connections[:clients].count}\e[0m"

        user_messages( user_name, client )
      end
    }.join
  end

  def user_messages( user_name, client )
    loop {
      msg = client.gets.chomp
      case msg
      when 'exit'
        puts "\e[#{31}m#{user_name} disconnected!\e[0m"
        @connections[:clients].delete(user_name)
        @connections[:clients].each do |other_name, other_client|
          if other_name != user_name
            other_client.puts "\e[#{31}m#{user_name} came out!\e[0m"
          end
        end
      else
        recipients = msg.scan(/\@(\w+)/).flatten
        if recipients.empty?
          send_all(user_name, msg)
        else
          send_private(recipients, user_name, msg)
        end
      end
    }
  end

  def send_all(user_name, msg)
    @connections[:clients].each do |other_name, other_client|
      if other_name != user_name
        other_client.puts "\e[#{33}m#{user_name}: #{msg}\e[0m"
      end
    end
  end

  def send_private(recipients, user_name, msg)
    @connections[:clients].each do |other_name, other_client|
      if recipients.include?(other_name)
        other_client.puts "#{user_name.to_s}(p): #{msg}"
      end
    end
  end
end
server = TCPServer.open( 'localhost', 3000 );
Server.new( server )
