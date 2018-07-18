class ChatRoomsController < ApplicationController
  before_action :set_chat_room, only: [:show, :edit, :update, :destroy, :chat, :user_admit_room, :user_exit_room]
  
  # GET /chat_rooms
  # GET /chat_rooms.json
  def index
    @chat_rooms = ChatRoom.all
  end

  # GET /chat_rooms/1
  # GET /chat_rooms/1.json
  def show
  end

  # GET /chat_rooms/new
  def new
    @chat_room = ChatRoom.new
  end

  # GET /chat_rooms/1/edit
  def edit
  end
  
  def user_admit_room
    # 현재 유저가 있는 방에서 Join을 눌렀을 때 동작하는 액션
    # 이미 조인한 유저라면 참가한 방입니다 alert
    if @chat_room.admissions_count < @chat_room.max_count
      if current_user.joined_room?(@chat_room)
          # Or another way is - chat_room.users.include?(current_user)
          # where function always returns an array object
        render js: "alert('you are already a member!');"
      else
      # 아닐 경우에는 참가
        @chat_room.user_admit_room(current_user)
      end
    end
  end
  
  def user_exit_room
    @chat_room.user_exit_room(current_user)
    if @chat_room.room_empty?
      @chat_room.destroy
    end
    redirect_to '/chat_rooms'
  end
  
  def chat
    @chat_room.chats.create(user_id: current_user.id, message: params[:message])
  end

  # POST /chat_rooms
  # POST /chat_rooms.json
  def create
    @chat_room = ChatRoom.new(chat_room_params)
    respond_to do |format|
      if @chat_room.save
        @chat_room.user_admit_room(current_user)
        format.html { redirect_to @chat_room, notice: 'Chat room was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /chat_rooms/1
  # PATCH/PUT /chat_rooms/1.json
  def update
    respond_to do |format|
      if @chat_room.update(chat_room_params)
        format.html { redirect_to @chat_room, notice: 'Chat room was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /chat_rooms/1
  # DELETE /chat_rooms/1.json
  def destroy
    @chat_room.user_exit_room(current_user)
    @chat_room.admissions.destroy_all
    @chat_room.destroy
    
    redirect_to root_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat_room
      @chat_room = ChatRoom.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chat_room_params
      params.fetch(:chat_room, {}).permit(:title, :max_count)
    end
    
end
