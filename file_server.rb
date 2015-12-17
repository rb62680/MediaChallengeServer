require 'socket'

include Socket::Constants

class FileServer
  def initialize
    @socket = Socket.new(AF_INET, SOCK_STREAM, 0)
    @socket.bind(Socket.sockaddr_in(62580, '0.0.0.0'))
  end

  def start_listening
    @socket.listen(5)
    loop do
      begin
        client_socket, client_addrinfo = @socket.accept_nonblock
        Process.fork{
          begin
            http_string = "HTTP/1.1 200 OK\r\nConnection: Keep-Alive\r\nContent-Type: audio/mpeg\r\n\r\n" + File.read('song.mp3')
            client_socket.write http_string
            client_socket.close
            exit(0)
          rescue Errno::EPIPE
            puts 'broken pipe'
            exit(0)
          end
        }
      rescue IO::WaitReadable, Errno::EINTR
        IO.select([@socket])
        retry
      end
    end
  end
end

server = FileServer.new
server.start_listening