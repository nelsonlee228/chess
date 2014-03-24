require "colorize"

class ChessInstance
  attr_reader :player1, :player2, :chess_map, :chess_set
  attr_accessor :valid_moves

  def initialize(player1, player2)
    @player1, @player2 = player1, player2
    @chess_set = MetaData.new
    @chess_map = @chess_set.create_coordinate
    @valid_moves = []
    sequence_rotation 
  end

  private 

  def sequence_rotation
    create_chesstable(valid_moves)
    game_log = GameLog.new(player1, player2)

    while not @chess_set.has_winner?
      turn = game_log.get_record
      if turn == player1
        puts "#{turn}'s turn".colorize(:red) << "\nPlease select a chess:".colorize(:yellow)
      else 
        puts "#{turn}'s turn".colorize(:blue) << "\nPlease select a chess:".colorize(:yellow)
      end
      chess = gets.chomp.to_sym 
      until (@chess_set.valid_chess?(whose_turn?(turn), chess) && @chess_set.valid_moves(chess))
        if not @chess_set.valid_chess?(whose_turn?(turn), chess)
          puts "This chess is invalid".colorize(:red)
        elsif not @chess_set.valid_moves(chess)
          puts "This chess has no where to move".colorize(:red)
        end
        chess = gets.chomp.to_sym 
      end
      puts "#{(@chess_set.valid_chess?(whose_turn?(turn), chess) && @chess_set.valid_moves(chess))}".colorize(:red)
      @valid_moves = @chess_set.valid_moves(chess)
      # puts "#{valid_moves}".colorize(background: :blue)
      # puts "#{valid_moves}".colorize(:green)
      create_chesstable(valid_moves)
      puts "Please select a coordinate:".colorize(:yellow)
      coordinate = gets.chomp
      until @chess_set.valid_coordinate?(valid_moves, coordinate)
        puts "This coordinate is invalid".colorize(:red)
        coordinate = gets.chomp 
      end
      type = @chess_set.move_type(coordinate)
      case type
      when "move"
        @chess_set.move_chess(chess, coordinate)
        puts "\nyou moved #{chess} to #{coordinate}".colorize(color: :green)
      when "kill"
        target = @chess_set.kill_chess(chess, coordinate)
        puts "\nYou killed #{target}".colorize(color: :green)
      end
      @valid_moves = []
      create_chesstable(valid_moves)
    end
    winner = @chess_set.whois_winner?
    winner == "user_1" ? winner = player1 : winner = player2 
    # print "\n".colorize(background: :green)
    puts "#{winner} has won the game!!".colorize(color: :green).blink
    # print "\n\n".colorize(background: :green)
  end

  def whose_turn?(turn)
    turn == player1 ? "user_1" : "user_2"
  end

  def create_chesstable(valid_moves)
    coincide_set = @chess_set.merge_sets
    # puts valid_moves.include? "43"
    # puts "#{coincide_set}".colorize(:green)
    column_header = ("a".."h").to_a.join("\s\s\s\s\s\s")
    2.times { print "\n" }
    6.times { print "\s" }
    print "#{column_header}".colorize(:yellow)
    print "\n"
    3.times { print "\s" }
    57.times { print "\s".colorize(background: :white) }
    print "\n"
    counter = 0
    for y in 1..9
      unless y == 9
        print "\s#{y}\s".colorize(:yellow)
        for x in "a".."h"
          print "\s".colorize(background: :white)
          if not coincide_set.key("#{x}#{y}")
            if valid_moves.include? "#{x}#{y}"
              6.times { print "\s".colorize(background: :yellow)}
            else
              6.times { print "\s".colorize(background: :white)}
            end
          else
            if coincide_set.key("#{x}#{y}")[0] == "r"
              if valid_moves.include? "#{x}#{y}"
                print "\s#{coincide_set.key("#{x}#{y}")}\s".to_s.colorize(background: :yellow, color: :black)
                print "\s".colorize(background: :red)
              else
                print "\s#{coincide_set.key("#{x}#{y}")}\s".to_s.colorize(background: :black, color: :white)
                print "\s".colorize(background: :red)
              end
            else
               if valid_moves.include? "#{x}#{y}"
                print "\s#{coincide_set.key("#{x}#{y}")}\s".to_s.colorize(background: :yellow, color: :black)
                print "\s".colorize(background: :red)
              else
                print "\s#{coincide_set.key("#{x}#{y}")}\s".to_s.colorize(background: :black, color: :white)
                print "\s".colorize(background: :blue)
              end
            end
          end
          unless x == "h"
            # print "\s"
          else
            print "\s".colorize(background: :white)
            print "\n"
            3.times { print "\s" }
            57.times { print "\s".colorize(background: :white) }
            print "\n"
          end
        end
      end
      counter += 1
    end
    2.times { print "\n" }
  end
end

class MetaData
  attr_accessor :meta_coordinate, :chess_set1, :chess_set2

  def initialize(meta_coordinate = {})
    @meta_coordinate = meta_coordinate
    @chess_set1 = { :rkg => "d1",
                    :rqn => "e1",
                    :rh1 => "g1",
                    :rh2 => "b1",
                    :rb1 => "f1",
                    :rb2 => "c1",
                    :rr1 => "h1",
                    :rr2 => "a1",
                    :rp8 => "a2",
                    :rp7 => "b2",
                    :rp6 => "c2",
                    :rp5 => "d2",
                    :rp4 => "e2",
                    :rp3 => "f2",
                    :rp2 => "g2",
                    :rp1 => "h2",
                  }
    @chess_set2 = { :bkg => "d8",
                    :bqn => "e8",
                    :bh1 => "g8",
                    :bh2 => "b8",
                    :bb1 => "f8",
                    :bb2 => "c8",
                    :br1 => "h8",
                    :br2 => "a8",
                    :bp8 => "a7",
                    :bp7 => "b7",
                    :bp6 => "c7",
                    :bp5 => "d7",
                    :bp4 => "e7",
                    :bp3 => "f7",
                    :bp2 => "g7",
                    :bp1 => "h7",
                    }

  end

  def create_coordinate
    for y in 1..8
      x_coordainte = 1
      for x in "a".."h"
        symbol = "#{x}#{y}".to_sym
        @meta_coordinate[symbol] = "#{x_coordainte}#{y}"
        x_coordainte += 1
      end
    end
    return @meta_coordinate
  end

  def merge_sets
    @chess_set1.merge(@chess_set2)
  end

  def has_winner?
     (chess_set1.has_key? :rkg) ^ (chess_set2.has_key? :bkg)
  end

  def valid_chess?(turn, chess)
    case turn
    when "user_1"
      if chess_set1[chess]
        true
      else
        false
      end
    when "user_2"
      if chess_set2[chess]
        true
      else
        false
      end
    end
  end

  def valid_coordinate?(valid_moves, coordinate)
    # puts "#{valid_moves}"
    # puts "#{coordinate}"
    valid_moves.include? coordinate
  end

  def valid_moves(chess)
    valid_moves = [] 
    chess_set = chess_set1.merge(chess_set2)
    if chess_set[chess]
      current_position = meta_coordinate[chess_set[chess].to_sym]
    else
      return false
    end
    # puts "#{current_position}".colorize(:green)
    position_x = current_position[0].to_i
    position_y = current_position[1].to_i
    if chess.slice(0) == "r"
      target_set, select_set = chess_set2, chess_set1
    else 
      target_set, select_set = chess_set1, chess_set2
    end
    case chess.slice(1)
    when "p"
      if chess.slice(0) == "r"
        x = 1
        while x <= 2  
          break if target_set.key( meta_coordinate.key("#{position_x}#{position_y+x}").to_s)
          valid_moves << meta_coordinate.key("#{position_x}#{position_y+x}").to_s
          x += 1
        end
        if  target_set.key( meta_coordinate.key("#{position_x-1}#{position_y+1}").to_s)
          valid_moves << meta_coordinate.key("#{position_x-1}#{position_y+1}").to_s
        end
        if target_set.key( meta_coordinate.key("#{position_x+1}#{position_y+1}").to_s)
          valid_moves << meta_coordinate.key("#{position_x+1}#{position_y+1}").to_s
        end
      else 
        x = 1
        while x <= 2  
          break if target_set.key( meta_coordinate.key("#{position_x}#{position_y-x}").to_s)
          valid_moves << meta_coordinate.key("#{position_x}#{position_y-x}").to_s
          x += 1
        end
        if  target_set.key( meta_coordinate.key("#{position_x+1}#{position_y-1}").to_s)
          valid_moves << meta_coordinate.key("#{position_x+1}#{position_y-1}").to_s
        end
        if target_set.key( meta_coordinate.key("#{position_x-1}#{position_y-1}").to_s)
          valid_moves << meta_coordinate.key("#{position_x-1}#{position_y-1}").to_s
        end
      end
    when "r"
      y_up = position_y + 1
      y_down = position_y - 1
      x_left = position_x - 1
      x_right = position_x + 1
      while y_up <= 8
        break if select_set.key( meta_coordinate.key("#{position_x}#{y_up}").to_s)
        valid_moves << meta_coordinate.key("#{position_x}#{y_up}").to_s
        break if target_set.key( meta_coordinate.key("#{position_x}#{y_up}").to_s)
        y_up += 1
      end
      while y_down >= 1
        break if select_set.key( meta_coordinate.key("#{position_x}#{y_down}").to_s)
        valid_moves << meta_coordinate.key("#{position_x}#{y_down}").to_s
        break if target_set.key( meta_coordinate.key("#{position_x}#{y_down}").to_s)
        y_down -= 1
      end
      while x_right <= 8 
        break if select_set.key( meta_coordinate.key("#{x_right}#{position_y}").to_s)
        valid_moves << meta_coordinate.key("#{x_right}#{position_y}").to_s
        break if target_set.key( meta_coordinate.key("#{x_right}#{position_y}").to_s)
        x_right += 1
      end
      while x_left >= 1 
        break if select_set.key( meta_coordinate.key("#{x_left}#{position_y}").to_s)
        valid_moves << meta_coordinate.key("#{x_left}#{position_y}").to_s
        break if target_set.key( meta_coordinate.key("#{x_left}#{position_y}").to_s)
        x_left -= 1
      end
    when "b"
      y_up = position_y + 1
      y_down = position_y - 1
      x_left = position_x - 1
      x_right = position_x + 1
      while (y_up <= 8) && (x_left >= 1)
        break if select_set.key( meta_coordinate.key("#{x_left}#{y_up}").to_s)
        valid_moves << meta_coordinate.key("#{x_left}#{y_up}").to_s
        break if target_set.key( meta_coordinate.key("#{x_left}#{y_up}").to_s)
        y_up += 1
        x_left -= 1
      end
      y_up, x_left = position_y + 1, position_x -1
      while (y_up <= 8) && (x_right <= 8)
        break if select_set.key( meta_coordinate.key("#{x_right}#{y_up}").to_s)
        valid_moves << meta_coordinate.key("#{x_right}#{y_up}").to_s
        break if target_set.key( meta_coordinate.key("#{x_right}#{y_up}").to_s)
        y_up += 1
        x_right += 1
      end
      y_up, x_right = position_y + 1, position_x + 1
      while (y_down >= 1) && (x_left >= 1)
        break if select_set.key( meta_coordinate.key("#{x_left}#{y_down}").to_s)
        valid_moves << meta_coordinate.key("#{x_left}#{y_down}").to_s
        break if target_set.key( meta_coordinate.key("#{x_left}#{y_down}").to_s)
        y_down -= 1
        x_left -= 1
      end
      y_down, x_left = position_y - 1, position_x - 1
      while (y_down >= 1) && (x_right <= 8)
        break if select_set.key( meta_coordinate.key("#{x_right}#{y_down}").to_s)
        valid_moves << meta_coordinate.key("#{x_right}#{y_down}").to_s
        break if target_set.key( meta_coordinate.key("#{x_right}#{y_down}").to_s)
        y_down -= 1
        x_right += 1
      end
      y_down, x_right = position_y - 1, position_x + 1
    when "h"
      if (not select_set.key( meta_coordinate.key("#{position_x + 2}#{position_y + 1}").to_s))
        valid_moves << meta_coordinate.key("#{position_x + 2}#{position_y + 1}").to_s if ((position_x+2) <= 8) && ((position_y+1) <= 8)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x - 2}#{position_y + 1}").to_s))
        valid_moves << meta_coordinate.key("#{position_x - 2}#{position_y + 1}").to_s if ((position_x-2) >= 1) && ((position_y+1) <= 8)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x + 2}#{position_y - 1}").to_s))
        valid_moves << meta_coordinate.key("#{position_x + 2}#{position_y - 1}").to_s if ((position_x+2) <= 8) && ((position_y-1) >= 1)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x - 2}#{position_y - 1}").to_s))
        valid_moves << meta_coordinate.key("#{position_x - 2}#{position_y - 1}").to_s if ((position_x-2) >= 1) && ((position_y-1) >= 1)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x - 1}#{position_y - 2}").to_s))
        valid_moves << meta_coordinate.key("#{position_x - 1}#{position_y - 2}").to_s if ((position_x-1) >= 1) && ((position_y-2) >= 1)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x + 1}#{position_y - 2}").to_s))
        valid_moves << meta_coordinate.key("#{position_x + 1}#{position_y - 2}").to_s if ((position_x+1) <= 8) && ((position_y-2) >= 1)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x - 1}#{position_y + 2}").to_s))
        valid_moves << meta_coordinate.key("#{position_x - 1}#{position_y + 2}").to_s if ((position_x-1) >= 1) && ((position_y+2) <= 8)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x + 1}#{position_y + 2}").to_s))
        valid_moves << meta_coordinate.key("#{position_x + 1}#{position_y + 2}").to_s if ((position_x+1) <= 8) && ((position_y+2) <= 8)
      end
    when "q"
      y_up = position_y + 1
      y_down = position_y - 1
      x_left = position_x - 1
      x_right = position_x + 1
      while y_up <= 8
        break if select_set.key( meta_coordinate.key("#{position_x}#{y_up}").to_s)
        valid_moves << meta_coordinate.key("#{position_x}#{y_up}").to_s
        break if target_set.key( meta_coordinate.key("#{position_x}#{y_up}").to_s)
        y_up += 1
      end
      y_up = position_y + 1
      while y_down >= 1
        break if select_set.key( meta_coordinate.key("#{position_x}#{y_down}").to_s)
        valid_moves << meta_coordinate.key("#{position_x}#{y_down}").to_s
        break if target_set.key( meta_coordinate.key("#{position_x}#{y_down}").to_s)
        y_down -= 1
      end
      y_down = position_y - 1
      while x_right <= 8 
        break if select_set.key( meta_coordinate.key("#{x_right}#{position_y}").to_s)
        valid_moves << meta_coordinate.key("#{x_right}#{position_y}").to_s
        break if target_set.key( meta_coordinate.key("#{x_right}#{position_y}").to_s)
        x_right += 1
      end
      x_right = position_x + 1
      while x_left >= 1 
        break if select_set.key( meta_coordinate.key("#{x_left}#{position_y}").to_s)
        valid_moves << meta_coordinate.key("#{x_left}#{position_y}").to_s
        break if target_set.key( meta_coordinate.key("#{x_left}#{position_y}").to_s)
        x_left -= 1
      end
      x_left = position_x - 1
      while (y_up <= 8) && (x_left >= 1)
        break if select_set.key( meta_coordinate.key("#{x_left}#{y_up}").to_s)
        valid_moves << meta_coordinate.key("#{x_left}#{y_up}").to_s
        break if target_set.key( meta_coordinate.key("#{x_left}#{y_up}").to_s)
        y_up += 1
        x_left -= 1
      end
      y_up, x_left = position_y + 1, position_x -1
      while (y_up <= 8) && (x_right <= 8)
        break if select_set.key( meta_coordinate.key("#{x_right}#{y_up}").to_s)
        valid_moves << meta_coordinate.key("#{x_right}#{y_up}").to_s
        break if target_set.key( meta_coordinate.key("#{x_right}#{y_up}").to_s)
        y_up += 1
        x_right += 1
      end
      y_up, x_right = position_y + 1, position_x + 1
      while (y_down >= 1) && (x_left >= 1)
        break if select_set.key( meta_coordinate.key("#{x_left}#{y_down}").to_s)
        valid_moves << meta_coordinate.key("#{x_left}#{y_down}").to_s
        break if target_set.key( meta_coordinate.key("#{x_left}#{y_down}").to_s)
        y_down -= 1
        x_left -= 1
      end
      y_down, x_left = position_y - 1, position_x - 1
      while (y_down >= 1) && (x_right <= 8)
        break if select_set.key( meta_coordinate.key("#{x_right}#{y_down}").to_s)
        valid_moves << meta_coordinate.key("#{x_right}#{y_down}").to_s
        break if target_set.key( meta_coordinate.key("#{x_right}#{y_down}").to_s)
        y_down -= 1
        x_right += 1
      end
      y_down, x_right = position_y - 1, position_x + 1
    when "k"
      if (not select_set.key( meta_coordinate.key("#{position_x}#{position_y + 1}").to_s))
        valid_moves << meta_coordinate.key("#{position_x}#{position_y + 1}").to_s if ((position_x) <= 8) && ((position_y+1) <= 8)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x}#{position_y - 1}").to_s))
        valid_moves << meta_coordinate.key("#{position_x}#{position_y - 1}").to_s if ((position_x) >= 1) && ((position_y-1) <= 8)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x + 1}#{position_y}").to_s))
        valid_moves << meta_coordinate.key("#{position_x + 1}#{position_y}").to_s if ((position_x+1) <= 8) && ((position_y) >= 1)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x - 1}#{position_y}").to_s))
        valid_moves << meta_coordinate.key("#{position_x - 1}#{position_y}").to_s if ((position_x-1) >= 1) && ((position_y) >= 1)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x - 1}#{position_y - 1}").to_s))
        valid_moves << meta_coordinate.key("#{position_x - 1}#{position_y - 1}").to_s if ((position_x-1) >= 1) && ((position_y-1) >= 1)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x + 1}#{position_y + 1}").to_s))
        valid_moves << meta_coordinate.key("#{position_x + 1}#{position_y + 1}").to_s if ((position_x+1) <= 8) && ((position_y+1) >= 1)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x - 1}#{position_y + 1}").to_s)) 
        valid_moves << meta_coordinate.key("#{position_x - 1}#{position_y + 1}").to_s if ((position_x-1) >= 1) && ((position_y+1) <= 8)
      end
      if (not select_set.key( meta_coordinate.key("#{position_x + 1}#{position_y - 1}").to_s)) 
        valid_moves << meta_coordinate.key("#{position_x + 1}#{position_y - 1}").to_s if ((position_x+1) >= 1) && ((position_y-1) <= 8)
      end
      # puts valid_moves
    end
    if valid_moves.count > 0
      return valid_moves
    else
      return false
    end
  end

  def move_type(coordinate)
    chess_set = @chess_set1.merge(@chess_set2)
    if chess_set.key(coordinate)
      "kill"
    else
      "move"
    end
    # target_position = meta_coordinate[chess_set[chess].to_sym]
  end

  def move_chess(chess, coordinate)
    # puts coordinate
    # puts meta_coordinate[coordinate.to_sym]
    if chess_set1[chess]
      chess_set1[chess] = coordinate
    elsif chess_set2[chess]
      chess_set2[chess] = coordinate
    end
  end

  def kill_chess(chess, coordinate)
    if chess_set1.key(coordinate)
      target = chess_set1.key(coordinate)
      chess_set1.delete_if {|key, value| value == coordinate }
      chess_set2[chess] = coordinate
    elsif chess_set2.key(coordinate)
      target = chess_set2.key(coordinate)
      chess_set2.delete_if {|key, value| value == coordinate }
      chess_set1[chess] = coordinate
    end
    return target
  end

  def whois_winner?
    if chess_set1.has_key? :rkg
      "user_1"
    elsif chess_set2.has_key? :bkg
      "user_2"
    end
  end
end

class GameLog
  attr_accessor :log
  attr_reader :turn, :user_1, :user_2

  def initialize(user_1, user_2, log = [], turn = nil)
    @user_1, @user_2, @log, @turn = user_1, user_2, log, turn
  end

  def get_record
    last_record = log.pop
    case last_record
    when user_1
      @turn = user_2
      @log << user_2
      return user_2
    when user_2, nil
      @turn = user_1
      @log << user_1
      return user_1
    else
      return "something went wrong".colorize(:red)
    end
  end

end

puts "Please enter the name for the" << "\sFIRST\s".colorize(:yellow) << "player"
player1 = gets.chomp.to_s
puts "Please enter the name for the" << "\sSECOND\s".colorize(:yellow) << "player"
player2 = gets.chomp.to_s

ChessInstance.new(player1, player2)
