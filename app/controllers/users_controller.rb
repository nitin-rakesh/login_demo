class UsersController < ApplicationController
	
	# skip_before_action :authenticate_user!
	before_filter :authenticate_user!
	def show
		@user = current_user
	end

	def edit
		@user = current_user
	end

	def update
		@user = current_user
		binding.pry
		if @user.update_attributes(user_params)
			Picture.create(:picturable_id=>current_user.id,:picturable_type=>params[:picturable_type],:image=>params[:image])
			redirect_to user_path(@user.id)
		else
			render :action => 'edit'
		end
	end

	protected

	def user_params
		params.require(:user).permit!
	end

end
