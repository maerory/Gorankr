class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :user_signed_in?, :current_user
  
  # 유저가 현재 로그인 되어있는지 세션에서 확인
  def user_signed_in?
    session[:sign_in_user].present?
  end
  
  # 유저가 로그인 되어있지 않으면 로그인으로 보냄
  def authenticate_user!
    redirect_to 'sign_in_path' unless user_signed_in?
  end
  
  # 유저가 로그인을 했으면 현재 유저 객체를 current_user에 저장해둠
  def current_user
    @current_user = User.find(session[:sign_in_user]) if user_signed_in?
  end
  
end
