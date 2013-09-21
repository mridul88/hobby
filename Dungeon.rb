class Dungeon
    attr_accessor :rooms, :player
    
    def intilize(player_name)
      @Player = Player.new(player_name)
      @rooms = []
    end 
    
    def add_room(number, des, connection)
      @rooms << Room.new(des, number, connection)
    end
    
    def start_game(room_no)
      @player.location = room_no
    end
 
    
    
    class Player
      attr_accessor :name, :location
      
      def initilaize(player_name)
        @name = player_name;
      end
      
    end
    
    class Room
      attr_accessor :des, :number, :connections
      
      def intiliaze(des, number, connections)
        @des = des
        @number = number
        @connections = connections
      end
     end
    
end