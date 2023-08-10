require 'faker'
require 'q3_data_report'

describe Q3_data_report do
    WORLD_ID = "1022"
    let(:game) do
        {:game=>"game_1", 
            :data=>{
                :players=>[], 
                :kills=>[]}
        }
    end
    let(:player) {{:id=>nil, :name=>nil}}
    let(:kill) {{:killer_id=>nil, :victim_id=>nil, :cause=>nil}}
    
    context 'Games info' do
        it 'should list games' do
            parsed_games = []
            
            (1..5).each do |g|
                new_game = game.clone
                new_game[:game] = "game_#{g}"
                parsed_games << new_game
            end

            data_report = Q3_data_report.new(parsed_games).report
            expect(data_report.length).to be 5
            (0..4).each do |g|
                expect(data_report[g]).to have_key "game_#{g+=1}"
            end
        end
    end
    context 'Players info' do
        it 'should list all players in a game' do
            parsed_players = []
            
            (1..5).each do |p|
                new_player = player.clone
                new_player[:id] = p.to_s
                new_player[:name] = Faker::Name.name    
                parsed_players << new_player
            end

            game[:data][:players] = parsed_players
            data_report = Q3_data_report.new([game]).report

            players_list = data_report.first["game_1"][:players]
            expect(players_list.length).to be 5
            expect(players_list).to match_array(parsed_players.collect{|p| p[:name]})
        end
    end
    context 'kills count' do
        it 'should have total_kills' do
            parsed_kills = []
            5.times{ parsed_kills << kill.clone}

            game[:data][:kills] = parsed_kills

            data_report = Q3_data_report.new([game]).report
            expect(data_report["game_1"][:total_kills]).to be_eql 5 
        end
        it 'should list players with their kills' do
            parsed_players = []
            (1..2).each do |p|
                new_player = player.clone
                new_player[:id] = p.to_s
                new_player[:name] = Faker::Name.name    
                parsed_players << new_player
            end

            kill[:killer_id] = parsed_players[0][:id]
            kill[:victim_id] = parsed_players[1][:id]

            game[:data][:players] = parsed_players
            game[:data][:kills] << kill

            data_report = Q3_data_report.new([game]).report
            kill_data = data_report.first["game_1"][:kills]

            expect(kill_data).to include(parsed_players[0][:name] => 1, parsed_players[1][:name] => 0)
        end
        it 'should not count a kill when player kills himself' do
            player[:id] = Random.rand(1..10)
            player[:name] = Faker::Name.name

            kill[:killer_id] = player[:id]
            kill[:victim_id] = player[:id]

            game[:data][:players] << player
            game[:data][:kills] << kill

            data_report = Q3_data_report.new([game]).report
            expect(data_report.first["game_1"][:kills][player[:name]]).to eql 0
        end
        it 'player should lose a kill when killed by world' do
            player[:id] = Random.rand(1..10)
            player[:name] = Faker::Name.name

            kill[:killer_id] = WORLD_ID
            kill[:victim_id] = player[:id]

            game[:data][:players] << player
            game[:data][:kills] << kill

            data_report = Q3_data_report.new([game]).report
            expect(data_report.first["game_1"][:kills][player[:name]]).to eql -1
        end
    end
    context 'death count' do
        it 'should count every player death' do
            parsed_players = []
            (1..2).each do |p|
                new_player = player.clone
                new_player[:id] = p.to_s
                new_player[:name] = Faker::Name.name    
                parsed_players << new_player
            end

            game[:data][:players] = parsed_players

            kill[:killer_id] = parsed_players[1][:id]
            kill[:victim_id] = parsed_players[0][:id]
            game[:data][:kills] << kill.clone

            kill[:killer_id] = parsed_players[0][:id]
            kill[:victim_id] = parsed_players[0][:id]
            game[:data][:kills] << kill.clone

            kill[:killer_id] = WORLD_ID
            kill[:victim_id] = parsed_players[0][:id]
            game[:data][:kills] << kill.clone

            data_report = Q3_data_report.new([game]).report
            expect(data_report.first["game_1"][:deaths][parsed_players[0][:name]]).to eql 3
        end
    end
    context 'death cause count' do
        it 'shoul count all death causes' do
            parsed_kills = []
            5.times do
                kill[:cause] = ["MOD_SHOTGUN", "MOD_GAUNTLET", "MOD_MACHINEGUN"].sample
                parsed_kills << kill.clone
            end

            game[:data][:kills] = parsed_kills

            death_causes = game[:data][:kills].collect{|k| k[:cause]}

            data_report = Q3_data_report.new([game]).report
            expect(data_report.first["game_1"][:death_causes]).to match_array(death_causes.tally)
        end
    end
end