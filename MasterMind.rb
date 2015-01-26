module MasterMind

  class Game(tries = 12, colors = 6, length = 4)
    def initialize
      @mode = nil
      @tries = tries
      @colors = colors
      @pattern = nil
      @pattern_len = length
      @pattern_range = ('a'..('a'.ord + @colors - 1).chr)
      @computer = Computer.new
    end

    def begin
      get_mode
      if @mode == 0
        print "Please enter a pattern in the form of a string using #{@pattern_range}'s (i.e. AAAA): "
        @pattern = get_pattern_from_user
        @pattern_len = @pattern.length

      elsif @mode == 1
        player_guess_init

        @tries.times do |n|
          guess = get_pattern_from_user("Guess ##{n + 1}: ")

          unless guess
            puts "Input not valid."
            redo
          end

          result = compare_guess(guess)
          if win?(result)
            puts "You WIN!"
            break
          else
            puts "X: #{result[:right]} | O: #{result[:colors]}"
            puts "Sorry the correct pattern was: #{(@pattern.join).upcase}. Better luck next time!" if n == @tries - 1
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
    def get_pattern_from_user(prompt = nil)
      print prompt if prompt
      input = gets.chomp
      input = input.downcase
      input = input.split('')

      input.each { |n| return false unless pattern_range.include?(n.downcase) }
      input
    end

    #have the computer class generate a pattern
    def get_pattern_from_comp
     @computer.gen_pattern(@pattern_len, @pattern_range)
    end

    #returns a hash of :right being the amount that are in the right position and color and :colors for the amount
    #correct colors out of position
    def compare_guess(guess)
      right = 0
      colors = 0

      guess.each_with_index do |n, i|
        if guess[i] == @pattern[i]
          right += 1
        elsif @pattern.include?(guess[i])
          colors += 1
        end
      end

      {right: right, colors: colors}
    end

    #displays instructions and generates a pattern
    def player_guess_init
      puts "You have 12 turns to guess the pattern. For each guess that is correct in both position and color "\
                "you will get an O, for each guess that is correct in color but not position you will get an X. Enter "\
                "your guess as a string of #{@pattern_len} (i.e. AAAA)"

      @pattern = get_pattern_from_comp
    end

    #checks a hash for the win condition
    def win?(guess)
      guess[:right] == @pattern.length
    end
  end

  class Computer

    #generates an array of random values of either b or w
    def gen_pattern(len, range)
      (1..len).map { range.to_a.sample }
    end

    def all_poss

    end

    def initial_guess(len, range)
      first = Array.new(len / 2, range.to_a[0])
      second = Array.new(len - first.length, range.to_a[1])
      first + second
    end
  end
end
