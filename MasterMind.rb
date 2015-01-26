module MasterMind

  class Game
    #initialize a game
    def initialize(tries = 12, colors = 6, length = 4)
      @mode = nil
      @tries = tries
      @colors = colors
      @pattern = nil
      @pattern_len = length
      @pattern_range = ('a'..('a'.ord + @colors - 1).chr)
      @computer = Computer.new
    end

    #get the mode and start a game loop
    def begin
      get_mode
      if @mode == 0
        @pattern = nil
        until @pattern && @pattern.length < 9
          puts "Please enter a pattern in the form of a string using #{@pattern_range}'s"\
                  " (i.e. AAAA) with a maximum length of 8 characters: "
          @pattern = get_pattern_from_user
        end

        @pattern_len = @pattern.length

        guess = @computer.initial_guess(@pattern_len, @pattern_range)

        (@tries).times do |n|
          result = @computer.compare_patterns(guess, @pattern)
          if win?(result)
            puts "I guessed the pattern #{guess.join.upcase} in #{n + 1} tries!"
            break
          else
            puts "#{guess.join.upcase} - X: #{result[:right]} | O: #{result[:colors]}"
            guess = @computer.next_guess(result)
            puts "Ahh you beat me! I should've known it was #{@patter.join.upcase}" if  n == @tries - 1
          end
        end
      elsif @mode == 1
        player_guess_init

        @tries.times do |n|
          guess = get_pattern_from_user("Guess ##{n + 1}: ")

          unless guess
            puts "Input not valid."
            redo
          end

          result = @computer.compare_patterns(guess, @pattern)
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
        @mode = nil
      end
    end

    #prompt the user to enter a pattern and make sure it fits the format or return false
    def get_pattern_from_user(prompt = nil)
      print prompt if prompt
      input = gets.chomp
      input = input.downcase
      input = input.split('')

      input.each { |n| return false unless @pattern_range.include?(n.downcase) }
      input
    end

    #displays instructions and generates a pattern
    def player_guess_init
      puts "You have 12 turns to guess the pattern. For each guess that is correct in both position and color "\
                "you will get an O, for each guess that is correct in color but not position you will get an X. Enter "\
                "your guess as a string of #{@pattern_len} (i.e. AAAA)"

      @pattern = @computer.gen_pattern(@pattern_len, @pattern_range)
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

    #populates an array of all possible solutions
    def populate_solutions(len, range)
      @solutions = range.to_a.repeated_permutation(len).to_a
    end

    #creates an initial guess with the first half being the first character in range and the second half being the second character
    def initial_guess(len, range)
      first = Array.new(len / 2, range.to_a[0])
      second = Array.new(len - first.length, range.to_a[1])
      @guess = first + second
      populate_solutions(len, range)
      @guess
    end

    #eliminates all solutions that would not yield the same result and grabs a random 1 from what's left
    def next_guess(result)
      @solutions = @solutions.select { |n| compare_patterns(@guess, n) == result }
      @guess = @solutions.sample
      @guess
    end

    #returns a hash of :right being the amount that are in the right position and color and :colors for the amount
    #correct colors out of position
    def compare_patterns(pat1, pat2)
      right = 0
      colors = 0

      pat1_clone = pat1.clone
      pat2_clone = pat2.clone

      pat1.each_with_index do |n, i|
        if pat1[i] == pat2[i]
          right += 1
          pat1_clone[i] = nil
          pat2_clone[i] = nil
        end
      end

      pat1_clone.each_with_index do |n, i|
        if n && pat2_clone.include?(n)
          colors += 1
          pat2_clone[pat2_clone.index(n)] = nil
        end
      end

      {right: right, colors: colors}
    end
  end
end
