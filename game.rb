require "colorize"

class Game
  attr_accessor :board, :ships, :shots

  def initialize
    intro
    @board = Board.new
    @shots = Board.new
    @ships = [ Ship.new(2, 'S')#, Ship.new(3, 'D1'),
               #Ship.new(3, 'D2'), Ship.new(4, 'C'),
               #Ship.new(5, 'A')
    ]
  end

  def set_ships_on_board
    @ships.each do |s|
      s.direction = rand(0..1)
      if s.direction == 1
        x = rand(0..9)
        while x+s.length < 10 or x-s.length < 10
          if x+s.length < 10 or x-s.length < 10
            y = rand(0..9)
            taken = false
            #Check if there is already a ship in place
            for i in (1..s.length)
              if @board.grid[i][y] != "0"
                taken = true
                break
              end
            end
            #If there is no ship, place the new one
            if !taken
              #put the ship here
              s.pos_y = y
              s.pos_x = x
              for i in (1..s.length)
                @board.grid[i][y] = s.name
                s.update_pos(i, y)
              end
              break
              # There is a place taken, so we need to generate a new point
            else
              x = rand(0..9)
            end
          else
            x = rand(0..9)
          end
        end
      else
        y = rand(0..9)
        while y+s.length < 10 or y-s.length < 10
          if y+s.length < 10 or y-s.length < 10
            x = rand(0..9)
            taken = false
            #Check if there is already a ship in place
            for i in (1..s.length)
              if @board.grid[x][i] != "0"
                taken = true
                break
              end
            end
            #If there is no ship, place the new one
            if !taken
              #put the ship here
              s.pos_y = y
              s.pos_x = x
              for i in (1..s.length)
                @board.grid[x][i] = s.name
                s.update_pos(x, i)
              end
              break
              # There is a place taken, so we need to generate a new point
            else
              y = rand(0..9)
            end
          else
            y = rand(0..9)
          end
        end
      end
    end
  end

  def intro
    puts
    puts "Here's how it works"
    puts
    puts "There are 5 battleships:"
    puts
    print "1x Submarine: "
    puts "1 1".colorize(:background => :red, :color => :black)
    puts
    print "2x Destroyer: "
    puts "1 1 1".colorize(:background => :red, :color => :black)
    puts
    print "1x Cruiser: "
    puts "1 1 1 1".colorize(:background => :red, :color => :black)
    puts
    print "1x Aircraft Carrier: "
    puts "1 1 1 1 1".colorize(:background => :red, :color => :black)
    puts
    puts "The aim is to sink all ships in as few tries as possible by"
    puts "entering the co-ordinates e.g. (A5)"
    puts
  end

  def check_shot(x=0, y=0)
    if board.grid[x][y] != 'M'
      if board.grid[x][y]!='0'
        check_ship(x,y)
        update_shots(x,y)
      else
        puts 'You missed!'
        @board.grid[x][y]='M'
      end
    else
      puts 'You are missing opportunities here!! Hit twice the same place??'
    end
  end

  def check_ship(x,y)
    if board.grid[x][y] != 'X'
      s = ships.detect {|s| s.name== board.grid[x][y]}
      puts 'Ship was hit: '+s.name
      s.pos.each do |p|
        if p[:x]==x and p[:y]==y
          p[:hit]=1
        end
      end
      #Check if the ship was sinked
      sink = s.pos.detect { |p| p[:hit]==0 }
      if sink.nil?
        puts 'Ship was '+s.name+' sunk!!'
      end
    else
      puts 'Are you a thunder?? Hit twice the same place??'
    end
  end

  def check_win
    win=true
    ships.each do |s|
      sink = s.pos.detect { |p| p[:hit]==0 }
      if !sink.nil?
        win=false
        break
      end
    end
    if win
      puts 'You won!!'
    end
    win
  end

  def update_shots(x,y)
    @shots.grid[x][y]='1'
    @board.grid[x][y]='X'
  end
end

class Ship
  attr_accessor :length, :pos_y, :pos_x, :name
  # 1 is vertical, 0 is horizontal
  attr_accessor :direction
  attr_accessor :pos

  def initialize(length, name)
    @length = length
    @name = name
    @pos = []
    @direction = 1
  end

  def update_pos(x=0, y=0)
    @pos << {:x=>x, :y=>y, :hit=>0}
  end
end

class Board
  attr_accessor :grid

  def initialize
    set_grid
  end

  def set_grid
    @grid = Array.new(10).map { Array.new(10, "0") }
  end

  def print_board
    column = *(0..9)
    row = *(0..9)

    print "\t"
    print row.join("\t")
    puts
    puts

    grid.each_with_index do |r, i|
      print column[i]
      print "\t"
      print r.join("\t")
      puts
      puts
    end

  end
end

def ready?
  tries = 0
  print "Welcome to my game of Battleships, are you ready? (y/n) "
  reply = gets.strip.downcase

  until reply == "y" or reply == "n"
    puts "Invalid reply, run again"
    print "Welcome to my game of Battleships, are you ready? (y/n) "
    reply = gets.strip.downcase
  end

  if reply == "y"
    game = Game.new
    game.set_ships_on_board
    game.board.print_board
    while reply == "y"
      print "Enter you shot (x,y): "
      fff = gets.chomp
      player_x = fff[0]
      player_y = fff[2]

      game.check_shot(player_y.to_i, player_x.to_i)
      print "Do you want to continue? (y/n) "
      reply = gets.strip.downcase
      game.board.print_board

      tries +=1

      if game.check_win
        puts 'You won in '+tries.to_s+' tries!'
        break
      end
    end
  else
    puts "Okay, come back when you're ready!"
  end
end

ready?
