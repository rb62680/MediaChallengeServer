class Client
  attr_accessor :room, :username

  def initialize (socket)
    @socket = socket

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
  end

  def start
    @thread = Thread.new do
      loop do
        begin
          p = @socket.read_nonblock(3)
          break if p.empty?
          length, opcode = p.unpack('SC')
          message = @socket.read_nonblock(length)
          process_message(length, opcode, message)
        rescue EOFError
          break
        rescue IO::WaitReadable
          IO.select([@socket])
          retry
        end
      end
      @socket.close
      @room.client_list.delete(self)
    end
  end

  def send_message (message)
    length = [message.length - 1]
    @socket.write(length.pack('S') + message)
  end

  def process_message(length, opcode, message)
    case opcode
    when 1 # Set username
      @username = message.unpack('A*')[0]
      @logger.info '[GameServer] Set username : ' + @username
    else
      @socket.close
      @room.client_list.delete(self)
      @thread.stop
    end
  end
end
