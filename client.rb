class Client
  attr_accessor :room, :username, :score

  def initialize (socket)
    @socket = socket

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @score = 0
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
      when 4 # message
        user_message = message.unpack('A*')[0]
        if (check_message(user_message))
          self.send_message [5, 'You found the answer! Congratulations!'].pack('CA*')
        else
          message = [5, "#{self.username} : #{user_message}"].pack('CA*')
          @logger.info '[GameServer] received message ' + user_message
          self.room.send_all message
        end
    else
      @socket.close
      @room.client_list.delete(self)
      @thread.stop
    end
  end

  def check_message message
    if (message.include? self.room.song[:artist]) || (message.include? self.room.song[:name])
      self.score += 1
      return true
    end
    false
  end
end
