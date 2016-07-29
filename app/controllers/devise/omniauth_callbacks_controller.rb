class Devise::OmniauthCallbacksController < ApplicationController
	skip_before_filter :authenticate_user!

	def facebook
    begin
      @user = User.from_facebook_omniauth(request.env['omniauth.auth'])
      session[:user_id] = @user.id
      sign_in @user
      flash[:success] = "Welcome, #{@user.name}!"
    rescue
      flash[:warning] = "There was an error while trying to authenticate you..."
    end
    binding.pry
    redirect_to user_path(@user.id)
  end

  def failure
    redirect_to root_path
  end

end
