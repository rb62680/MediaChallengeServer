require 'socket'
require_relative 'client'
require_relative 'room'
require_relative 'room_manager'

include Socket::Constants

class Server
  #attr_accessor :socket, :client_list

  def initialize
    @socket = Socket.new(AF_INET, SOCK_STREAM, 0)
    @socket.bind(Socket.sockaddr_in(62300, '0.0.0.0'))
    @room_manager = RoomManager.instance
  end

  def start_listening
    @socket.listen(5)
    loop do
      begin
        client_socket, client_addrinfo = @socket.accept_nonblock
        puts 'A new client connected'
        client = Client.new(client_socket)
        client.room = @room_manager.add_client_in_room(client)
        client.start
      rescue IO::WaitReadable, Errno::EINTR
        IO.select([@socket])
        retry
      end
    end
  end
end

server = Server.new
server.start_listening
