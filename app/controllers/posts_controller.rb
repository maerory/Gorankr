class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :create_comment]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @user_likes_post = Like.where(user_id: current_user.id, post_id: @post.id).first
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    
  end
  
  def like_post
    #현재 유저와 params에 담긴 post 간의 좋아요 관계를 설정
    # Create function combines both new and save
    @like = Like.where(user_id: current_user.id, post_id: params[:post_id]).first
    if @like.nil?
      @like = Like.create(user_id: current_user.id, post_id: params[:post_id])
    else
      @like.destroy
    end
    #@like.frozen?
    # 현 유저가 이미 좋아요를 눌렀을 경우, 해당 Like 인스턴스 삭제
    # 새로 눌렀을 때만 좋아요 관계 설정
  end
  
  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)
    @post.user_name = current_user.user_name
    @post.game_name = params[:game_name]
    @post.user_id = current_user.id
    @post.category_id = session[:current_category_id]
    if @post.save
      session.delete(:current_game_name)
      redirect_to "/board/#{@post.game_name}/#{@post.id}", flash: {success: "Post Created"}
    else
      render :new
    end
  end  
  
  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def create_comment
    @comment = Comment.create(user_name: current_user.user_name, post_id: @post.id, content: params[:content])
  end

  def destroy_comment
    @comment = Comment.find(params[:comment_id]).destroy
  end

  def update_comment
    @comment = Comment.find(params[:comment_id])
    @comment.update(content: params[:content])
  end
  
  def upload_image
    @image = Image.create(image_path: params[:upload][:image])
    render json: @image
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      # params.require(:post).permit(:title, :content)
      params.fetch(:post, {}).permit(:title, :content)
    end
end
