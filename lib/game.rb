require_relative 'player'
require 'json'
require 'pathname'

class Game
    attr_reader :correct_guess,:incorrect_guess, :answer
    @@guessword = []
    def initialize(player)
        @@guessword = initialize_wordlist
        @number_of_guess = 10
        @player = player
        @correct_guess = []
        @incorrect_guess = []
        @answer = []
    end 


    def initialize_wordlist
        wordbank = File.open("../wordbank.txt")
        wordbank.each_line do |line|
            if line.length <= 12 && line.length >=5
                line = line.downcase
                @@guessword.push(line)
            end 
        end 
        @@guessword
        
       
    end 

  
    
    def generate_guessword
         guess =  @@guessword.sample
         len = guess.length
         len -=1

         len.times do 
            @answer.push("_")
         end 

         puts(guess)
         return guess
    end 

    def receive_guess
        begin
            print("--------------------- \n")           
            print("Hi, enter your guess. It must be a single letter. Or type save to save your game! \n")
            guess = gets.strip
            return "save" if guess == "save"
            raise "Invalid input!" unless guess.length == 1 && guess.match?(/[[:alpha:]]/)
            raise "You already guessed this!" if (@incorrect_guess.include?("#{guess}") || @correct_guess.include?("#{guess}"))
            guess.downcase
        rescue StandardError => e
            puts("Something went wrong. Read the line below to see what error:", e)
            retry
        end
    end 


    def evaluate_guess(guess,key)
        
        if key.include? guess
            arr_of_index = get_arr_of_index(guess,key)
            construct_answer(arr_of_index,guess)
            @correct_guess.push(guess)
            print("Correct! \n",)

            if @answer.none?("_")
                return "success"
            end 
        else 
            @player.number_of_guess = @player.number_of_guess - 1
            @incorrect_guess.push(guess)
            print("Incorrect! \n")
        end
    end 

    def print_hint
        print("Your correct guesses: ", @correct_guess)
        print("\n")
        print("Your incorrect guesses: ", @incorrect_guess)
        print("\n")
    end 


    def get_arr_of_index(guess,key)
        arr_index = []
        key.each_char.with_index do |char,index|
            if(char == guess) 
                arr_index.push(index)
            end
        end 
        arr_index
    end 


    def construct_answer(arr_of_index,char_to_insert)
        arr_of_index.each do |index|
            @answer[index] = char_to_insert
        end
    end

   
   
end

def get_name
    puts "Enter name for saving/opening game"
    file_name = gets.strip
end 

def save_game(game)
    file_name = get_name
    unless (check_name(file_name) == "success")
        puts("Name already existed or invalid. Try again:")
        file_name = get_name
    end 
    saved_file = game.to_json
    File.open("../saved/#{file_name}.json" , 'w') { |f| f.write(saved_file) }
    puts("Saved successfully!")
end 

def load_game
    file_name = get_name
    if (check_name(file_name) == "success")
        puts("File doesn't exist. Try again:")
        file_name = get_name
    end 
    saved = File.open("../saved/#{file_name}.json" , 'r')
    game = JSON.parse(saved)
    saved.close
    game
end

def check_name(file_name)
    Dir.mkdir("../saved") unless Dir.exist?("../saved")
    if (File.exist?("../saved/#{file_name}.json"))
        return "failure"
    end
    "success"
end 


def start_game
    #default 10 guesses, in this instance, player have 5 guesses
    player = Player.new(5)
    game = Game.new(player)
    key = game.generate_guessword
    loop do 
        guess = game.receive_guess
        result = game.evaluate_guess(guess,key)
        print("The word so far: ", game.answer)
        print("\n")
        game.print_hint

        break if (player.number_of_guess == 0 || result == "success")
    end 
end 

# start_game

player = Player.new(5)
game = Game.new(player)

save_game(game)