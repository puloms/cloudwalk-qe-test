class Q3_data_report
    WORLD_ID = "1022"

    attr_reader :report

    def initialize(games)
        @games = games
        calculate_report
    end

    def calculate_report
        @report = []
        #Run block for each game in parsed info
        #It'll calculated and return to report
        @games.each do |game|
            @report << calculate(game[:game], game[:data])
        end
    end

    private

    def calculate(game_number, data)
        kills_and_deaths = calculate_kills_and_deaths(data)
        return {
            game_number => {
                total_kills: data[:kills].length,
                players: data[:players].collect{|p| p[:name]},
                kills: kills_and_deaths[:kills],
                deaths: kills_and_deaths[:deaths],
                death_causes: calculate_death_causes(data[:kills])
            }
        }
    end

    private

    #Used to calculate kills and deaths, since this informations are togheter in parsed info, this method will call
    #each one separately
    def calculate_kills_and_deaths(data)
        kills = {}
        deaths = {}
        data[:players].each do |p|
            kills[p[:name]] = calculate_kills_for_player(p[:id], data[:kills])
            deaths[p[:name]] = calculate_deaths_for_player(p[:id], data[:kills])
        end
        return {kills: kills, deaths: deaths}
    end

    def calculate_kills_for_player(player_id, kills_data)
        #Second condition here ensures player will not receive a kill count whe kills himself
        kills = kills_data.select{|k| k[:killer_id] == player_id && k[:killer_id] != k[:victim_id]}.length

        #Remove one kill with player died by world
        kills-=kills_data.select{|k| k[:killer_id] == WORLD_ID && k[:victim_id] == player_id}.length
        return kills
    end

    def calculate_deaths_for_player(player_id, kills_data)
        kills_data.select{|k| k[:victim_id] == player_id}.length
    end

    def calculate_death_causes(data)
        death_causes = {}
        causes = data.collect{|k| k[:cause]}
        causes.uniq.each do |c|
            death_causes[c] = causes.count(c)
        end
        return death_causes
    end
end