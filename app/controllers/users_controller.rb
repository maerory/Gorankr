class UsersController < ApplicationController
    
    # 큐 버튼?
    def index
    end
    
    # 마이페이지
    def user_info
        @user = User.find(session[:sign_in_user])
    end
    
    # 회원가입 페이지
    def sign_up
    end
    # 회원가입 로직
    def user_sign_up
        @user = User.new(user_name: params[:user_name],
                        password: params[:password],
                        password_confirmation: params[:password_confirmation],
                        age: params[:age],
                        discord: params[:discord])
        if @user.save
            redirect_to root_path, flash: {success: "회원가입 성공, 로그인해 주세요" }
        else
            redirect_to :back, flash: {success: "회원가입 실패"}
        end
    end
    
    # 로그인 페이지
    def sign_in
    end
    # 로그인 로직
    def user_sign_in
        @user = User.find_by(user_name: params[:user_name])
        if @user.present? and @user.authenticate(params[:password])
            session[:sign_in_user] = @user.id
            redirect_to index_path, flash: {success: "로그인 성공"}
        else
            redirect_to :back, flash: {success: "로그인 실패"}
        end
    end
    
    def game_link
        @user = User.find(session[:sign_in_user])
    end
    
    ## 게임 아이디 연동 업데이트 하기
    
    def user_game_link
       if current_user.update({
           lol_id: params[:lol_id].nil? ? current_user.lol_id : params[:lol_id], 
           ow_id: params[:ow_id].nil? ? current_user.ow_id : params[:ow_id], 
           pubg_id: params[:pubg_id].nil? ? current_user.pubg_id : params[:pubg_id]})
           redirect_back(fallback_location: root_path, flash: {success: "연동 성공"})
       else
           redirect_back(fallback_location: root_path, flash: {success: "연동 실패"})
       end
    end
    
    ## LOL API를 호출하는 함수
    def fetch_lol_data
        # 먼저 다른 정보를 가져오기 위한 소환사의 summonerId 와 accountId를 가져온다
        url = URI.encode("https://kr.api.riotgames.com/lol/summoner/v3/summoners/by-name/#{current_user.lol_id}?api_key=#{ENV["LOL_API_KEY"]}")
        puts url
        user_lol_info = RestClient.get(url)
        user_lol_info = JSON.parse(user_lol_info)
        @summonerId = user_lol_info["id"]
        @accountId = user_lol_info["accountId"]
        
        # AccountId를 이용해 솔랭 게임의 정보를 가져온다
        url = URI.encode("https://kr.api.riotgames.com/lol/match/v3/matchlists/by-account/#{@accountId}?queue=420&api_key=#{ENV["LOL_API_KEY"]}")
        puts url
        user_lol_matches = RestClient.get(url)
        user_lol_matches = JSON.parse(user_lol_matches)
        user_lanes = []
        user_lol_matches["matches"].each do |match|
            user_lanes.push(match["lane"])
        end
        user_lanes = Hash[user_lanes.group_by(&:itself).map {|k,v| [k, v.size] }]
        user_lanes = user_lanes.sort_by {|k, v| v}.reverse
        @pos1 = user_lanes[0][0]
        @pos2 = user_lanes[1][0]
        
        # SummonerId를 이용해 티어를 가져온다
        url = URI.encode("https://kr.api.riotgames.com/lol/league/v3/positions/by-summoner/#{@summonerId}?api_key=#{ENV["LOL_API_KEY"]}")
        puts url
        user_lol_league = RestClient.get(url)
        user_lol_league = JSON.parse(user_lol_league)
        @tier = user_lol_league[0]["tier"]
    end
    
    def fetch_pubg_data
        # PubG opgg 점수 크롤링 
        # url = "https://pubg.op.gg/user/bokeyems?server=pc-krjp"
        # page = Nokogiri::HTML(open(url))
        # puts ("asdf")
        # page.css('div .matches-item__my-ranking').each do |n|
        #     puts n
        # end
    end
    
    def fetch_ow_data
        ow_id = current_user.ow_id.gsub!("#","-")
        
        # 오버와치 점수 가져오기
        url = URI.encode("https://www.overbuff.com/players/pc/" + ow_id)
        page = Nokogiri::HTML(open(url))
        @mmr = page.css("span .player-skill-rating").text

        # 오버와치 포지션 가져오기
        url = URI.encode("https://www.overbuff.com/players/pc/" + ow_id + "?mode=competitive")
        page = Nokogiri::HTML(open(url))
        @pos = page.xpath("/html/body/div[1]/div[3]/div/div[3]/div[2]/div[2]/div/section/article/table/tbody/tr[1]/td[1]/a/img").attr("alt")
    end
    
    # 로그 아웃
    def sign_out
        session.delete(:sign_in_user)
        redirect_to root_path, flash: {warning: "로그 아웃"}
    end
    
    # 회원정보 수정 페이지
    def edit
        @user = User.find_by_user_name(params[:user_name])
    end
    # 회원정보 수정 로직
    def update
        @user = User.find_by_user_name(params[:user_name])
        if @user.update({password: params[:password], age: params[:age], discord: params[:discord]})
            redirect_to user_info_path(@user), notice: 'User information updated.'
        else
            redirect_to :back, notice: 'Could not change user info'
        end
    end

private
    def user_params
        {password: params[:password], age: params[:age], discord: params[:discord]} 
    end
end
