class PlayersController < ApplicationController

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
        
        if @player.save
            redirect_to root_path, flash: {success: "큐가 돌아가고 있습니다" }
        else
            redirect_to :back, flash: {success: "큐 조인 실패"}
        end
    end

end
