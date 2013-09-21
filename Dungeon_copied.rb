#!/usr/local/bin/ruby
#
# dungeon.rb: dungeon state + operations to add/remove objs, open doors, etc.
#   - Each object is represented as a simple string, and the intent is that
#     each object would be in just one location.
#
# This file contains unit test code; to run it, type
#       ruby dungeon.rb
#

# uncomment following require to enable debugging
#   - see http://www.uwplatt.edu/csse/tools/ruby/ruby-debug.html
#require 'ruby-debug'

# Captures state of the dungeon
class Dungeon
  attr_reader   :rooms          # type: list(Room)
  attr_reader   :pack           # type: BackPack
  attr_accessor :current_room   # type: Room - room character is in

  # initialize: init dungeon w/ no rooms and an empty backpack
  def initialize
    @rooms = {}
    @pack  = BackPack.new
  end

  # returns the item's location, either a room or the backpack
  #   If the item is not in the dungeon, returns nil.
  def location_of(item)
    return @pack if @pack.has?(item)
    @rooms.each { |id, r|
      return r if r.has?(item)
    }
    return nil
  end

  # Add the room to the dungeon
  def add(room)
    raise "Illegal room: #{room.inspect}" unless room.class == Room
    puts "Room #{room.id} already exists." if @rooms[room.id]
    @rooms[room.id] = room
    @current_room = room unless @current_room
  end

  # removes item from dungeon, effectively destroying it
  def remove(item)
    loc = location_of(item)
    loc.remove(item)
  end
end

######################################################################

# places where objects can be
class Location
  attr_accessor :contents       # type: Hash(String -> Boolean)
                                #       (effectively a set)

  # initialize so the list of objects is empty
  def initialize
    @contents = {}
  end

  # does this location have the specified object?
  def has?(item)
    ! @contents[item].nil?
  end

  # add object to this location if it is not already present
  def add(item)
    if ! has?(item)
      @contents[item] = true
    end
  end
    
  # remove object from this location
  def remove(item)
    @contents.delete(item)
  end

protected

  # return list of contents for status reports
  def sorted_contents
    @contents.keys.sort
  end
end

# information about a particular room
class Room < Location

  attr_reader :id               # string identifier for room
  attr_reader :exits            # hash from directions to room names
                                #   giving open doors out of the room
  attr_accessor :entry, :action # source code to execute on entry
                                #   and after executing certain actions

  # room identifier + code to execute
  def initialize(id, code = [])
    super()
    @id = id
    @exits = {}
    action_index = code.index('action:')
    if action_index
      @entry  = code.shift(action_index)
      code.shift                # skip the action: label
      @action = code
    else
      @entry  = code
      @action = []
    end
  end

  # list all objects in the room
  def describe_objects
    sorted_contents.each { |obj|
      article = 'aeiou'.include?(obj[0..0].downcase) ? 'an' : 'a'
      puts "There is #{article} #{obj} on the ground."
    }
  end

  # display status of room as specified in writeup
  def show_status
    puts "Status for room #{id}:"
    if @contents.empty?
      puts "  The room is empty."
    else
      puts "  Contents: #{sorted_contents.join(', ')}"
    end
    if @exits.empty?
      puts "  No exits."
    else
      doors = []
      doors << 'north' if @exits[:north]
      doors << 'south' if @exits[:south]
      doors << 'east'  if @exits[:east]
      doors << 'west'  if @exits[:west]
      puts "  There are exits to the #{doors.join(', ')}."
    end
  end

  # returns true iff there is a door in the specified direction
  #   Direction must be :north, :south, :east, or ;west
  def open?(direction)
    ! @exits[direction].nil?
  end

  # open a door leading to the given destination
  def open(direction, destination)
    @exits[direction] = destination
  end
end    

# the status of the character's backpack
class BackPack < Location
  
  # show status of backpack by listing its contents
  #   The list is in alphabetical order for concreteness.
  def show_status
    if @contents.empty?
      puts "Your backpack is empty."
    else
      puts "Backpack contents:"
      puts "  #{sorted_contents.join(', ')}"
    end
  end

end

# class for exception to raise when the character dies
class Death < Exception
end

if __FILE__ == $0

  # code to test the dungeon classes; to execute, type
  #     ruby dungeon.rb

  class AssertionError < StandardError
  end
  
  def assert a
    raise AssertionError, "#{a.inspect}" unless a
  end
  
  #uncomment following to check assertion works:
  #assert false
  
  # test dungeon and related classes:

  d = Dungeon.new
  a = Room.new('A')
  b = Room.new('B', [:one, :two, 'action:', :three, :four])
  assert b.entry  == [:one, :two]
  assert b.action == [:three, :four]
  d.add(a)
  d.add(b)
  assert d.current_room == a

  assert d.location_of('pear').nil?
  a.add('pear')
  assert d.location_of('rock').nil?
  d.current_room.add('rock')
  b.add('hammer')
  assert a.has? 'pear'
  assert a.has? 'rock'
  assert b.has? 'hammer'
  assert !a.has?('hammer')
  
  d.pack.add('wine')

  assert d.location_of('hammer') == b
  assert d.location_of('rock')   == a
  assert d.location_of('wine')   == d.pack

  assert !a.open?(:east)
  a.open(:east, b)
  assert a.open?(:east)

  d.remove('wine')
  assert d.location_of('wine').nil?
  assert !d.pack.has?('wine')
  d.remove('rock')
  assert !a.has?('rock')
  assert d.location_of('rock').nil?

  puts "All tests pass."

end
