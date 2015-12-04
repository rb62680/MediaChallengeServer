class Room
  attr_accessor :client_list, :max_capacity

  def initialize
    @max_capacity = 5
    @client_list = []
  end
end
