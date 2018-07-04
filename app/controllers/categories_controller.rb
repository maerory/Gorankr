class CategoriesController < ApplicationController
    def index
        @categories = Category.all
    end
    
    def show
        @category = Category.find(params[:game_name])
        session[:current_category] = @category.id
    end
    
    def new
        @category = Category.new
    end
    
    def create
        @category = Category.new(category_params)
        if @category.save
            redirect_to root_path, flash: {success: "게임 등록 완료"}
        else
            redirect_to :back, flash: {danger: "카페 개설 실패"}
        end
    end
    

private
    def category_params
        params.require(:category).permit(:game_name)
    end

end
