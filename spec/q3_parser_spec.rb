require 'faker'
require 'q3_parser'

describe Q3_parser do
    before do
        allow(File).to receive(:exist?).with('test_file.log').and_return(true)
        allow(File).to receive(:exist?).with('unexisted_test_file.log').and_return(false)
    end

    context 'log file' do
        it 'exists and instantiate a parser' do
            parser = Q3_parser.new('test_file.log')
            expect(parser).to be_an_instance_of(Q3_parser)
        end
        it 'throws error if not exists' do
            parser = nil
            expect{parser = Q3_parser.new('unexisted_test_file.log')}.to raise_error("Could not find log file unexisted_test_file.log")
            expect(parser).to be_nil
        end
    end

    context 'parse games info' do
        it 'should found 3 games' do
            allow(File).to receive(:readlines).with('test_file.log').and_return(["  0:00 InitGame: \n", "20:37 InitGame: \n","981:27 InitGame: "])
            
            parser = Q3_parser.new('test_file.log')
            parser.parse

            (0..2).each do |g|
                expect(parser.games[g]).to include({:game=>"game_#{g+1}"})
            end
        end
        it 'should found 3 kill info in one game' do
            player1_id = Random.rand(1..10)
            player2_id = Random.rand(1..10)
            player2+=1 if player1_id == player2_id

            allow(File).to receive(:readlines).with('test_file.log')
            .and_return(["  0:00 InitGame:", 
                " 20:54 Kill: 1022 #{player1_id} 22: <world> killed player1 by MOD_TRIGGER_HURT\n",
                " 22:18 Kill: #{player1_id} #{player2_id} 7: player1 killed player2 by MOD_RAILGUN\n",
                "  2:11 Kill: #{player1_id} #{player1_id} 6: player1 killed player1 by MOD_ROCKET_SPLASH\n"])
            
            parser = Q3_parser.new('test_file.log')
            parser.parse

            expect(parser.games[0]).to match({:data=>
                                                {:kills=>
                                                  [{:cause=>"MOD_TRIGGER_HURT",
                                                    :killer_id=>"1022",
                                                    :victim_id=>"#{player1_id}"},
                                                   {:cause=>"MOD_RAILGUN",
                                                    :killer_id=>"#{player1_id}",
                                                    :victim_id=>"#{player2_id}"},
                                                   {:cause=>"MOD_ROCKET_SPLASH",
                                                    :killer_id=>"#{player1_id}",
                                                    :victim_id=>"#{player1_id}"}],
                                                 :players=>[]},
                                               :game=>"game_1"})
        end
        it 'should found 3 players in one game' do
            player1 = {id: 5, name: Faker::Name.name}
            player2 = {id: 6, name: Faker::Name.name}
            player3 = {id: 7, name: Faker::Name.name}

            allow(File).to receive(:readlines).with('test_file.log')
            .and_return(["  0:00 InitGame:", 
                " 1:19 ClientUserinfoChanged: #{player1[:id]} n\\#{player1[:name]}\\t\\0\\model\\xian/default\\hmodel\\xian/default\\g_redteam\\\\g_blueteam\\\\c1\\4\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0\n",
                " 1:21 ClientUserinfoChanged: #{player2[:id]} n\\#{player2[:name]}\\t\\0\\model\\uriel/zael\\hmodel\\uriel/zael\\g_blueteam\\\\g_redteam\\\\c1\\5\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0\n",
                " 2:05 ClientUserinfoChanged: #{player3[:id]} n\\#{player3[:name]}\\t\\0\\model\\sarge\\hmodel\\sarge\\g_redteam\\\\g_blueteam\\\\c1\\5\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0\n"])
            
            parser = Q3_parser.new('test_file.log')
            parser.parse
            
            expect(parser.games[0]).to match({:game=>"game_1", 
                                                :data=>
                                                {:players=>
                                                    [{:id=>"5", :name=>player1[:name]},
                                                     {:id=>"6", :name=>player2[:name]}, 
                                                     {:id=>"7", :name=>player3[:name]}],
                                                :kills=>[]}})
        end
        it 'should have the last player name' do
            player1 = {id: 5, name: Faker::Name.name}
            player1_new_name = Faker::Name.name

            allow(File).to receive(:readlines).with('test_file.log')
            .and_return(["  0:00 InitGame:", 
                " 1:19 ClientUserinfoChanged: #{player1[:id]} n\\#{player1[:name]}\\t\\0\\model\\xian/default\\hmodel\\xian/default\\g_redteam\\\\g_blueteam\\\\c1\\4\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0\n",
                " 1:21 ClientUserinfoChanged: #{player1[:id]} n\\#{player1_new_name}\\t\\0\\model\\uriel/zael\\hmodel\\uriel/zael\\g_blueteam\\\\g_redteam\\\\c1\\5\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0\n"])
            
            parser = Q3_parser.new('test_file.log')
            parser.parse

            expect(parser.games[0]).to match({:game=>"game_1", :data=>{:players=>[{:id=>"5", :name=>player1_new_name}], :kills=>[]}})
        end
    end
end