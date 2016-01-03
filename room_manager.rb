require 'singleton'

class RoomManager
  include Singleton

  attr_accessor :room_list, :file_server

  def initialize
    @file_server = nil
    @room_list = []
    @current_id = 0
  end

  ##
  # Finds the first room which isn't full
  def find_room
    room = @room_list.find{ |room| room.client_list.size < room.max_capacity }
    if room.nil?
      room = Room.new(@file_server, @current_id)
      puts 'Room id : ' + room.id.to_s
      @current_id += 1
      @room_list << room
    end
    room
  end

  def get_room_by_id id
    @room_list.each do |room|
      if room.id == id
        return room
      end
    end
    nil
  end

  def add_client_in_room (client)
    room = find_room()
    room.client_list << client
    client.room = room
    client.send_message([2, room.id].pack('CL'))
    room.start_room unless room.started
    room
  end
end
