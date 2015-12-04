class Client
  attr_accessor :room, :username

  def initialize (socket)
    @socket = socket
  end

  def start
    @thread = Thread.new do
      loop do
        begin
          p = @socket.read_nonblock(3)
          puts "Message recu"
          break if p.empty?
          length, opcode = p.unpack('SC')
          puts length
          puts opcode
          message = @socket.read_nonblock(length)
          process_message(length, opcode, message)
        rescue IO::WaitReadable
          IO.select([@socket])
          retry
        end
      end
      @socket.close
      @room.client_list.delete(self)
    end
  end

  def process_message(length, opcode, message)
    case opcode
    when 1 # Set username
      @username = message.unpack('A*')[0]
      puts "Set username : " + @username
    else
      @socket.close
      @room.client_list.delete(self)
      @thread.stop
    end
  end
end
