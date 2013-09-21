#!/usr/local/bin/ruby
#
# ifi.rb: interactive fiction interpreter
#

# Name: Stephen Corcoran
# Course: CS352 
# Description: Interactive Fiction Interpreter.
#              I did the extensions for the first test of the extension test.           

$:.push 'D:/documents/Ruby Programs/First_Ruby Project/'
require 'Dungeon_copied'

# print an error message and quit - useful for reporting parse erros
#   rest_of_code is an array of strings and helps in knowing what
#   part of the input has not been parsed yet. Note that you do not
#   have to call this function - reporting errors can be helpful
#   but is not required for the assignment.
def report_error(message, rest_of_code = [])
  abort "Error: #{message}\n -- remaining code: #{rest_of_code.join(' ')}"
end

# class to hold the results of parsing the input file
class Story

  # Initializes the dungeon.
  def initialize
    @dungeon = Dungeon.new
  end

  # main routine for parsing and executing a story
  #   - read in the list of rooms, then execute the commands
  def do_story(code)
    begin
      load_room_list(code)
      check_for("do:", code)
      run(@dungeon.current_room.entry)
      while !code.empty?
        do_command_list(code)
      end
    rescue
      puts "You die."
    end
  end

protected

  # run the instructions for a room.
  #   This needs to create a copy of the code so that any changes
  #   to the list (such as removing items that have been parsed)
  #   will not result in permanent changes to the code for the room.
  def run(code)
    # create copy of the room
    copy = code.clone
    # execute the code
    do_instruction_list(copy, true)
  end

  # Checks for a certain token in the given code.
  def check_for(token, code)
    if code[0] != token
      report_error("Expected #{token}, got #{code[0]}", code[1..-1])
    end
    code.shift
  end
  
  # Will run the entire load_room code while the code is not "do:"
  def load_room_list(code)
    while code[0] != 'do:'
      load_room(code)
    end
  end
  
  # Gets the id for the current room, puts all of the room code in a variable
  # then adds a new room to the dungeon.
  def load_room(code)
    id = code.shift
    room_code = []
    check_for('{', code)
    while code[0] != '}'
      room_code << code.shift
    end
    check_for('}', code)
    room = Room.new(id, room_code)
    @dungeon.add(room)
  end
  
  # Executes a command based upon the code given.
  def do_command_list(code)
    cmd = code.shift
    case cmd
      when 'take'
        execute_take(code)
      when 'go'
        execute_go(code)
      when 'status'
        execute_status
      when 'inventory'
        execute_inventory
      when 'look'
        execute_look
    end
  end
  
  # Prints out inventory then shows the status of the backpack.
  def execute_inventory
    puts "> inventory"
    @dungeon.pack.show_status
  end
  
  # Checks for "else", "end" and if the code is not empty, then
  # performs the instructions given along with a flag.
  def do_instruction_list(code, flag)
    while !code.empty? && code[0] != 'else' && code[0] != 'end'
      do_instruction(code, flag)
    end
  end
  
  # Uses the code and flag passed in to execute the instructions
  # for the current room.
  def do_instruction(code, flag)
    cmd = code.shift
    case cmd
      when 'add'
        execute_add(code, flag)
      when 'open'
        execute_open(code, flag)
      when 'print'
        execute_print(code, flag)
      when 'if'
        execute_if(code, flag)
      when 'die'
        raise @dungeon.Death.new
      when 'look'
        execute_look
    end
  end
  
  # Looks for "in pack", then returns if the object is in the pack or not.
  def check_test(code)
    obj = code.shift
    check_for('in', code)
    if code[0] == 'pack'
      check_for('pack', code)
      return @dungeon.pack.has?(obj)
    elsif code[0] == 'room'
      check_for('room', code)
      return @dungeon.current_room.has?(obj)
    end
  end
  
  # Looks to see if the item is in the backpack/room and if the flag is true,
  # then prints the appropriate message and adds the item to the room.
  def execute_add(obj, flag)
    item_obj = obj.shift
    if !@dungeon.location_of(item_obj) && flag
      puts "The #{item_obj} is on the ground."
      @dungeon.current_room.add(item_obj)
    end
  end
  
  # Checks for the direction, then looks to see if the room is not open and
  # if the flag is true, then opens a room with the given direction and room.
  def execute_open(code, flag)
    direction = check_direction(code)
    check_for("to", code)
    room_id = code.shift
    if !@dungeon.current_room.open?(direction) && flag
      @dungeon.current_room.open(direction, @dungeon.rooms[room_id])
      puts "A door to the #{direction} opens."
    end
  end
  
  # Checks for the directions and returns them in the format of :direction
  def check_direction(code)
    direction = code.shift
    if(direction == 'north' || direction == 'south' || 
       direction == 'east'  || direction == 'west')
      return direction.to_sym
    end
  end
  
  # Will look for the open ( then shift all the code inside of the ( and ) 
  # then will print out that code within there.
  def execute_print(code, flag)
    msg = []
    check_for('(', code)
    while code[0] != ')' && !code.empty?
      msg << code.shift
    end
    check_for(')', code)
    if flag then puts msg.join(' ') end
  end
  
  # First test to see if the item is found or not, then looks for a then
  # statement. If the test and flag is true then you want to perform the 
  # instruction list with a true paramater. Once you fall out of that you
  # want to check for an else, then perform the instruction_list with a 
  # false parameter. Then you want to do the same for the else statement
  # if the test and flag are false. Finally you want to check for the end.
  def execute_if(code, flag)
    test = check_test(code)
    check_for("then", code)
    if test && flag
      do_instruction_list(code, true)
      if code[0] == 'else'
        code.shift
        do_instruction_list(code, false)
      end
    else
      do_instruction_list(code, false)
      if code[0] == 'else'
        code.shift
        do_instruction_list(code, flag)
      end       
    end
    check_for("end", code)
  end
  
  # You want to check to see if the current room has the item, if so
  # you want to add it to the pack, then remove it from the room.
  def execute_take(obj)
    item_obj = obj.shift
    puts "> take #{item_obj}"
    if @dungeon.current_room.has?(item_obj)
      puts "You pick up the #{item_obj}."
      @dungeon.pack.add(item_obj)
      @dungeon.current_room.remove(item_obj)
      run(@dungeon.current_room.action)
    else
      puts "Cannot find #{item_obj}."
    end
  end
  
  # Checks if the direction is valid, then will see if the current
  # room is open or not, if so then update the current_room.
  def execute_go(code)
    direction = check_direction(code)
    puts "> go #{direction}"
    if @dungeon.current_room.open?(direction)
      @dungeon.current_room = @dungeon.current_room.exits[direction]
      run(@dungeon.current_room.entry)
    else
      puts "You bump your nose on the wall."
    end
  end
  
  # Will print out the current status of the current room.
  def execute_status
    puts "> status"
    @dungeon.current_room.show_status
  end
  
  # Will destory a given object which will remove it from 
  # anywhere in the dungeon.
  def execute_destroy(code)
    obj = code.shift
    if @dungeon.location_of(item)
      @dungeon.remove(item)
    end
  end
  
  # Lists all the objects in the current room.
  def execute_look
    puts "> look"
    @dungeon.current_room.describe_objects
  end
  
  # Will remove the item from a players backpack and
  # drop it in the room.
  def execute_drop(code)
    item = code.shift
    if !@dungeon.pack.has?(item)
      puts "You do not have the #{item}"
    else
      @dungeon.pack.remove(item)
      @dungeon.current_room.add(item)
    end
  end
end

# returns an array of words read from stdin
# type: none -> void
def get_input()
  input = []
  while line = gets
    input << line
  end
  input.map { |line| line.chomp! }
  #puts ">>>>>>>>"; input.each { |l| puts l }; puts ">>>>>>>>"
  # remove comments
  input.delete_if { |line| line =~ /^\s*#/ }
  result = input.join(' ').split
  #puts ">>>>>>>>"; puts result.join(' '); puts "<<<<<<<<<"
  return result

end

# input: array of lines; if empty, reads lines from stdin
# Read input, break it into two components, set up the world, 
# parse the story, and run the story.
def main(input = "")
  if input.empty?
    input = get_input
  else
    input = input.join(' ').split
  end

  story = Story.new
  story.do_story(input)
end

if __FILE__ == $0

  if false         # debugging
    
    puts "\n*** Using hardcoded tests ***\n"
    
    main(['Minimal { } do: status'])
    main(['Single { add crate } do: take crate'])
    main(['Single { print ( Hello, world! ) } do: status'])
    main(['Single { add crate open north to Single',
          ' if crate in pack then print ( found ) end }',
          ' do: take crate go north'])
    
# expected output:

# > status
# Status for room Minimal:
#   The room is empty.
#   No exits.
# The crate is on the ground.
# > take crate
# You pick up the crate.
# Hello, world!
# > status
# Status for room Single:
#   The room is empty.
#   No exits.
# The crate is on the ground.
# A door to the north opens.
# > take crate
# You pick up the crate.
# > go north
# found

  else
    
    main
    
  end
end
