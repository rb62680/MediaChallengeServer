require 'socket'
require 'logger'
require 'webrick'

include Socket::Constants

class FileServer
  attr_accessor :song

  def initialize
    @socket = Socket.new(AF_INET, SOCK_STREAM, 0)
    @socket.bind(Socket.sockaddr_in(62580, '0.0.0.0'))

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO

    @song = 'mp3/default.mp3'
  end

  def start_listening
    @socket.listen(5)
    loop do
      begin
        # Listening on socket
        client_socket, client_addrinfo = @socket.accept_nonblock
        @logger.info('[Fileserver] A client asked for the song')

        # Parse HTTP request
        room = get_room_id client_socket.gets

        # Send the song in a new process as ruby has a Global Interpreter Lock which may lock the whole server
        Process.fork {
          begin
            unless room.nil?
              http_string = "HTTP/1.1 200 OK\r\nConnection: Keep-Alive\r\nContent-Type: audio/mpeg\r\n\r\n" + File.read(room.song)
              client_socket.write http_string
              client_socket.close
            end
            client_socket.close
            exit(0)
          rescue Errno::EPIPE
            client_socket.close
            exit(0)
          end
        }
      rescue IO::WaitReadable, Errno::EINTR
        IO.select([@socket])
        retry
      end
    end
  end

  def get_room_id(request_line)
    request_uri  = request_line.split(" ")[1]
    path         = URI.unescape(URI(request_uri).path)

    clean = []

    # Split the path into components
    parts = path.split("/")

    parts[1]
  end
end
