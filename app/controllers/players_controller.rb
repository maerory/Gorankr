class PlayersController < ApplicationController
    # 현재 큐를 돌리고 있는 게이머들을 관리하고 큐를 직접 잡아준다.
    
    # 큐에 들어갈 유저정보를 담아서 player 모델 데이터를 생성해준다
    def create
        @player = Player.new
        @player.user_name = current_user.user_name
        @player.age = current_user.age
        @player.game_name = params[:game_name]
        @player.online = true
        if @player.game_name == "lol"
            url = URI.encode("https://kr.api.riotgames.com/lol/summoner/v3/summoners/by-name/#{current_user.lol_id}?api_key=#{ENV["LOL_API_KEY"]}")
            user_lol_info = RestClient.get(url)
            user_lol_info = JSON.parse(user_lol_info)
            summonerId = user_lol_info["id"]
            accountId = user_lol_info["accountId"]
            
            # AccountId를 이용해 솔랭 게임의 정보를 가져온다
            url = URI.encode("https://kr.api.riotgames.com/lol/match/v3/matchlists/by-account/#{accountId}?queue=420&api_key=#{ENV["LOL_API_KEY"]}")
            user_lol_matches = RestClient.get(url)
            user_lol_matches = JSON.parse(user_lol_matches)
            user_lanes = []
            user_lol_matches["matches"].each do |match|
                user_lanes.push(match["lane"])
            end
            user_lanes = Hash[user_lanes.group_by(&:itself).map {|k,v| [k, v.size] }]
            user_lanes = user_lanes.sort_by {|k, v| v}.reverse
            
            pos1 = user_lanes[0][0]
            pos2 = user_lanes[1][0]
            
            # SummonerId를 이용해 티어를 가져온다
            url = URI.encode("https://kr.api.riotgames.com/lol/league/v3/positions/by-summoner/#{summonerId}?api_key=#{ENV["LOL_API_KEY"]}")
            user_lol_league = RestClient.get(url)
            user_lol_league = JSON.parse(user_lol_league)
            
            tier = user_lol_league[0]["tier"] 
            rank = user_lol_league[0]["rank"]
            lp = user_lol_league[0]["leaguePoints"].to_i
            
            # 가져온 데이터를 전체 점수로 환산함
                
            tier_table = {
                "DIAMOND" => 2500,
                "PLATINUM" => 2000,
                "GOLD" => 1500,
                "SILVER" => 1000,
                "BRONZE" => 500,
            }
            
            mmr = 0
            if ["MASTER", "CHALLENGER"].include? tier
                mmr = 2500 + lp
            else
                mmr = tier_table[tier] - rank.length * 100 + lp
            end
            @player.game_data = {mmr: mmr, pos1: pos1, pos2: pos2 }
        end
        
        if @player.game_name == "pubg"
            # PubG opgg 점수 크롤링 
            mmrs = Array.new
            url = "https://dak.gg/profile/" + current_user.pubg_id
            page = Nokogiri::HTML(open(url))
            solo_mmr = page.xpath('//*[@id="profile"]/div[3]/div[1]/section[1]/div[1]/div[1]/div[2]/span[1]').text.tr(',','').to_i
            duo_mmr = page.xpath('//*[@id="profile"]/div[3]/div[1]/section[2]/div[1]/div[1]/div[2]/span[1]').text.tr(',','').to_i
            squad_mmr = page.xpath('//*[@id="profile"]/div[3]/div[1]/section[3]/div[1]/div[1]/div[2]/span[1]').text.tr(',','').to_i
            
            [solo_mmr, duo_mmr, squad_mmr].each do |score|
                if score != 0
                    mmrs.push(score)
                end
            end
            average_mmr = (mmrs.inject :+) / mmrs.length
            
            @player.game_data = {mmr: average_mmr }
        end
        
        if @player.game_name == "ow"
            ow_id = current_user.ow_id.gsub!("#","-")
        
            # 오버와치 점수 가져오기
            url = URI.encode("https://www.overbuff.com/players/pc/" + ow_id)
            page = Nokogiri::HTML(open(url))
            mmr = page.css("span .player-skill-rating").text
    
            # 오버와치 포지션 가져오기
            url = URI.encode("https://www.overbuff.com/players/pc/" + ow_id + "?mode=competitive")
            page = Nokogiri::HTML(open(url))
            pos = page.xpath("/html/body/div[1]/div[3]/div/div[3]/div[2]/div[2]/div/section/article/table/tbody/tr[1]/td[1]/a/img").attr("alt")
            @player.game_data = {mmr: mmr, pos1: pos}
        end
        
        @player.save
    end

    
    # 2인 큐를 잡아주는 알고리즘
    def duo_match
        player = Player.find_by_user_name(current_user.user_name)
        Player.where(game_name: player.game_name).all.each do |other_player|
            if (player.age - other_player.age).abs > 3 || player.game_name != other_player.game_name
                next
            end
            
            if (player.game_data["mmr"] - other_player.game_data["mmr"]).abs > 200
                next
            end
            
            # 플레이어들 넣어줄 채팅방 만들기
            @chat_room = ChatRoom.new
            matched_player = User.find_by_user_name(other_player.user_name)
            # 플레이어 어드미션 만들어주기
            Admission.create({:chat_room => @chat_room.id, :user => current_user.id})
            Admission.create({:chat_room => @chat_room.id, :user => matched_player.id})
            # 채팅방으로 리다이렉트 해주기
            Pusher.trigger("user_#{current_user.id}", 'match', self.as_json)
            Pusher.trigger("user_#{matched_player.id}", 'match', self.as_json)
            # 플레이어 데이터 삭제하기
            Player.destroy
            other_player.destroy
            break
        end
    end
    
    # 롤 5인큐를 잡아주는 알고리즘
    def team_match_lol
        player = Player.find_by_user_name(current_user.user_name)
        team = [player]
        roles = [player.game_data["pos1"]]
        Player.where(game_name: "lol").all.each do |other_player|
            if (player.age - other_player.age).abs < 3 && other_player.game_name == "lol" && (player.game_data["mmr"] - other_player.game_data["mmr"]).abs < 200 && roles.exclude?(other_player.game_data["pos1"])
                    roles.push(other_player.game_data["pos1"])
                    team.push(other_player.user_name)
            end
        end
        if team.length == 5
            @chat_room = ChatRoom.new
            team.each do |member|
                matched_user = User.find_by_user_name(member.user_name)
                Admission.create({:chat_room => @chat_room.id, :user => matched_user.id})
                Pusher.trigger("user_#{matched_user.id}", 'match', self.as_json)
            end
        end
    end
    
    # 배그 4인큐를 잡아주는 알고리즘
    def team_match_pubg
        player = Player.find_by_user_name(current_user.user_name)
        team = [player]
        Player.where(game_name: "pubg").all.each do |other_player|
            if (player.age - other_player.age).abs < 3 && other_player.game_name == "pubg" && (player.game_data["mmr"] - other_player.game_data["mmr"]).abs < 200 && team.length < 4
                team.push(other_player.user_name)
            end
        end
        if team.length == 4
                @chat_room = ChatRoom.new
                team.each do |member|
                    matched_user = User.find_by_user_name(member.user_name)
                    Admission.create({:chat_room => @chat_room.id, :user => matched_user.id})
                    Pusher.trigger("user_#{matched_user.id}", 'match', self.as_json)
            end
        end
    end
    
    
end
