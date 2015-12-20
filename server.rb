require 'socket'
require 'logger'
require_relative 'client'
require_relative 'room'
require_relative 'room_manager'
require_relative 'file_server'

include Socket::Constants

class Server
  def initialize
    @socket = Socket.new(AF_INET, SOCK_STREAM, 0)
    @socket.bind(Socket.sockaddr_in(62300, '0.0.0.0'))

    @room_manager = RoomManager.instance

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger.info('[GameServer] Server started')

    self.start_file_server
  end

  def start_file_server
    Thread.new {
      @file_server = FileServer.new
      RoomManager.instance.file_server = @file_server
      @logger.info '[FileServer] Server started'
      @file_server.start_listening
    }
  end

  def start_listening
    @socket.listen(5)
    loop do
      begin
        client_socket, client_addrinfo = @socket.accept_nonblock
        @logger.info('[GameServer] A new client connected')
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
