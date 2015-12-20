class Room
  attr_accessor :client_list, :max_capacity, :started, :song, :id

  SONGS = [
      {
          name: 'Hello',
          artist: 'Adele',
          file: 'mp3/adele-hello.mp3'
      }
  ]

  def initialize(file_server, id)
    @max_capacity = 5
    @client_list = []
    @file_server = file_server
    @started = false
    @id = id

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
  end

  def start_room
    Thread.new {
      @logger.info '[GameServer] room started'
      game_loop
      @started = true
    }
  end

  def game_loop
    while(self.client_list.size > 0)
      @logger.info '[GameServer] song generated'
      generate_song
      sleep(30)
      send_scores
    end
    @logger.info '[GameServer] Room deleted'
    RoomManager.instance.room_list.delete(self)
  end

  def send_scores
    @logger.info '[GameServer] scores!'
  end

  def generate_song
    @song = SONGS.sample[:file]
    message = [2].pack('C')
    self.client_list.each do |client|
      client.send_message message
    end
  end
end
