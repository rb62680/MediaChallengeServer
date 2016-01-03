class Room
  attr_accessor :client_list, :max_capacity, :started, :song, :id

  SONGS = [
      {
          name: 'Hello',
          artist: 'Adele',
          file: 'mp3/adele-hello.mp3'
      },
      {
          name: 'So wie du bist',
          artist: 'MoTrip',
          file: 'mp3/default.mp3'
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
    self.started = true
    Thread.new {
      @logger.info "[GameServer] room #{@id} started"
      game_loop
    }
  end

  def game_loop
    while(self.client_list.size > 0)
      @logger.info "[GameServer] Room #{@id} : song generated"
      generate_song
      sleep(30)
      send_scores
    end
    @logger.info "[GameServer] Room #{@id} deleted"
    RoomManager.instance.room_list.delete(self)
  end

  def send_scores
    @logger.info "[GameServer] Room #{@id} : scores!"
    score_text = "Game over!\nThe answer was: #{self.song[:artist]} - #{self.song[:name]}\nScores: \n"
    self.client_list.each do |client|
      score_text += "#{client.username}: #{client.score}\n"
    end
    message = [5, score_text].pack('CA*')
    send_all message
  end

  def generate_song
    @song = SONGS.sample
    message = [3].pack('C')
    send_all message
  end

  def send_all message
    self.client_list.each do |client|
      client.send_message message
    end
  end
end
