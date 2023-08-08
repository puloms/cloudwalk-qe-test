class Q3_parser
    INIT_GAME = /.*InitGame.*/
    KILL = /.*Kill.*: (.*) killed (.*) by (.*)$/
    PLAYER = /.*ClientUserinfoChanged.*/

    attr_accessor :games

    def initialize(file_path)
        if File.exist?(file_path)
            @file_path = file_path
        end
    end

    def parse
        @games = []
        @game_number = 0
        @data = {}
        File.readlines(@file_path).each do |line|
            new_game if line.match(INIT_GAME)
            kill_data(line.match(KILL)) if line.match(KILL)

            #    data[:data][:kills] << line
           # end

            #if line.match(PLAYER)
            #    data[:data][:players] << line
            #end
        end
    end

    private

    def new_game
        @game_number+=1
        @data = {game: "game_#{@game_number}", data: {players: [], kills: []}}
        @games << @data      
    end

    def kill_data(kill_data)
        kill_info = {killer: kill_data[1], victim: kill_data[2], cause: kill_data[3]}
        @data[:data][:kills] << kill_info
    end
end
    
    