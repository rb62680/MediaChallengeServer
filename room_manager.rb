require 'singleton'

class RoomManager
  include Singleton

  def initialize
    @room_list = [Room.new]
  end

  ##
  # Finds the first room which isn't full
  def find_room
    room = @room_list.find{ |room| room.client_list.size < room.max_capacity }
    if room.nil?
      room = Room.new
      @room_list << room
    end
    room
  end

  def add_client_in_room (client)
    room = find_room()
    room.client_list << client
    room
  end
end
