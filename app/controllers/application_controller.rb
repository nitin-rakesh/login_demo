class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  # before_action :authenticate_user! , :unless => :devise_controller?
  before_action :load_filter

  def load_filter
    if params[:key].present?
      authenticate_user_from_token!
    else
      authenticate_user!
    end
  end

  def authenticate_user_from_token!
    key = params[:key].presence
    user = key && User.find_by_key(key)
    if user.nil?
      render :status=>401, :json=>{:status=>"Failure", :status_code => 401, :message=>"Invalid Key."}
      return
    end
    access_token = AccessToken.where(:token => params[:authentication_token]).last
    if user && Devise.secure_compare(access_token.token, params[:authentication_token]) && access_token.present?
      sign_in user, store: true
    else
      render :status=>401, :json=>{:status=>"Failure", :status_code => 401, :message=>"Invalid Authentication token."}
      return
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: [:email, :first_name, :last_name, :user_name, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_in, keys: [:email, :password]
    devise_parameter_sanitizer.permit :account_update, keys: [:email, :first_name, :last_name, :username]
  end
end
