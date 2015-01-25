module MasterMind

  class Game
    def initialize
      @pattern = nil
      @mode = nil
      @computer = Computer.new
    end

    def begin
      get_mode
      if @mode == 0
        @pattern = get_pattern_from_user
      elsif @mode == 1
        puts "You have 12 turns to guess the pattern. For each guess that is correct in both position and color "\
                "you will get an O, for each guess that is correct in color but not position you will get an X. Enter "\
                "your guess as a string of 4 characters of B or W (i.e. bwwb)"

        @pattern = get_pattern_from_comp
        12.times do |n|
          print "Guess ##{n + 1}: "
          guess = get_pattern_from_user

          if guess
            result = compare_guess(guess)
            if result[:right] == @pattern.length
              puts "You WIN!"
              break
            else
              puts "X: #{result[:right]} | O: #{result[:colors]}"
              puts "Sorry the correct pattern was: #{@pattern.join}. Better luck next time!" if n == 11
            end
          else
            puts 'That input is not valid, please try again.'
            redo
          end
        end
      end
    end

    private #----------------------------------------------------------------------------------------------------------------------------------
    #Prompt the user to enter a game mode
    def get_mode
      print "Would you like to (m)ake the code or try to (g)uess it? (m/g): "
      input = gets.chomp

      if input.downcase == 'm'
        @mode = 0
      elsif input.downcase == 'g'
        @mode = 1
      else
        puts "That is not a valid selection."
        return nil
      end
    end

    #prompt the user to enter a pattern and make sure it fits the format or return false
    def get_pattern_from_user
      input = gets.chomp
      input = input.downcase
      input = input.split('')

      input.each { |n| return false unless n.downcase == 'b' || n.downcase == 'w' }
      input
    end

    #have the computer class generate a pattern
    def get_pattern_from_comp
     @computer.gen_pattern
    end

    def compare_guess(guess)
      right = 0
      guess.each_with_index { |n, i| right += 1 if guess[i] == @pattern[i] }

      pat_b = @pattern.count('b')
      guess_b = guess.count('b')

      colors = (4 - right) - (pat_b - guess_b).abs

      {right: right, colors: colors}
    end
  end

  class Computer

    #generates a 4 element array of random values of either b or w
    def gen_pattern
      (1..4).map { ['b', 'w'].sample }
    end
  end

end
