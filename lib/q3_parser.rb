class Q3_parser
    INIT_GAME = /.*InitGame.*/
    KILL = /.*Kill: ([0-9]*) ([0-9]*).*: .* killed .* by (.*)\n/
    PLAYER = /.*ClientUserinfoChanged: (\d*) n\\(.*)\\t\\.*$/

    attr_reader :games

    def initialize(file_path)
        raise "Could not find log file #{file_path}" unless File.exist?(file_path)
        @file_path = file_path
        parse
    end

    def parse
        @games = []
        @game_number = 0
        @data = {}

        #block will run for every line of the file, for every match it will call it's respective method
        File.readlines(@file_path).each do |line| 
            new_game if line.match(INIT_GAME)
            kill_parse(line.match(KILL)) if line.match(KILL)
            player_parse(line.match(PLAYER)) if line.match(PLAYER)
        end
    end

    private

    #Parse infos of a new game, using @game_number as a control variable
    def new_game
        @game_number+=1
        @data = {game: "game_#{@game_number}", data: {players: [], kills: []}}
        @games << @data      
    end

    #Parse infos of a kill using id
    def kill_parse(kill_info)
        kill_data = {killer_id: kill_info[1], victim_id: kill_info[2], cause: kill_info[3]}
        @data[:data][:kills] << kill_data
    end

    #Parse infos of players, if player change name middle game, this method will update it using id
    #In the end of the game, the last name used by the user will be in the parsed infos
    def player_parse(player_info)
        player_data = {id: player_info[1], name: player_info[2]}
        @data[:data][:players].map do |p|
             if p[:id] == player_data[:id] 
                p[:name] = player_data[:name] 
                return
            end
        end
        @data[:data][:players] << player_data
    end
end
    
    