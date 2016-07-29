class TokensController < ApplicationController
  skip_before_action :load_filter
  skip_before_action :authenticate_user!
  include ActionController::MimeResponds
  include ActionController::Cookies

  respond_to :json
  
  def create
    if params[:email].blank?
      render :status => 400,:json => {:status=>"Failure",:message=>"Email Address is required"} and return
    else
      render :status => 400,:json => {:status=>"Failure",:message=>"Another account is already using this email address"} and return if user_exist = User.find_by_email(params[:email]) and user_exist.present?
    end
    render :status => 400,:json => {:status=>"Failure",:message=>"Username is required"} and return if params[:user_name].blank?
    render :status => 400,:json => {:status=>"Failure",:message=>"Password is required"} and return if params[:password].blank?
    @user = User.new(:email => params[:email],:first_name => params[:first_name],
          :user_name => params[:user_name],:password => params[:password])
    if @user.save
      @token = @user.ensure_authentication_token
      sign_in @user, store: true
      render :status => 200, :json => { :status=>"Success",:key => @user.key,:authentication_token => @token.token,:user_id => @user.id}
    else
      render :status => 200, :json => { :status=>"Failure",:message=>"Registeration Failed Error: #{@user.errors.values.join(", ")}."}
    end
  end

  def get_key
    email = params[:email]
    password = params[:password]
    render :status=>406, :json=>{:status=>"Failure",:message=>"The request must be json"} and return if request.format != :json
    
    render :status=>400,:json=>{:status=>"Failure",:message=>"The request must contain the email and password."} and return if email.nil? or password.nil?
    @user=User.find_by_email(email.downcase)
 
    if @user.nil?
      logger.info("User #{email} failed signin, user cannot be found.")
      render :status=>401, :json=>{:status=>"Failure",:message=>"Invalid email"}
      return
    end
    

    if not @user.valid_password?(password)
      logger.info("User #{email} failed signin, password \"#{password}\" is invalid")
      render :status=>401, :json=>{:status=>"Failure",:message=>"Invalid password."}
    else
      @token = @user.ensure_authentication_token
      @user.save
      render :status=>200, :json=>{:status=>"Success", :authentication_token => @token.token,:key=>@user.key}
    end
  end
  
  def user_sign_up
    if params[:email].blank?
      render :status => 400,
              :json => {:status=>"Failure",:message=>"Email Address is required"}
       return
    else
      user_exist = User.find_by_email(params[:email])  
      if user_exist.present?
        render :status => 400,
                :json => {:status=>"Failure",:message=>"Another account is already using this email address"}
        return
      end   
    end
    
    if params[:user_name].blank?
      render :status => 400,
              :json => {:status=>"Failure",:message=>"Username is required"}
       return
    end
    if params[:password].blank?
      render :status => 400,
              :json => {:status=>"Failure",:message=>"Password is required"}
       return
    end
    @user = User.new({:email => params[:email],
          :first_name => params[:first_name],
          :last_name => params[:last_name],
          :user_name => params[:user_name],
          :password => params[:password]
                })
    if @user.save
      sign_in @user, store: true
      render :status => 200, :json => { :status=>"Success",
              :key => @user.key,
              :authentication_token => @user.authentication_token,
              :user_id => @user.id
              }

    else
      logger.info @user.errors.inspect
      render :status => 200, :json => { :status=>"Failure",:message=>"Registeration Failed Error: #{@user.errors.values.join(", ")}."}
    end
  end
  
  def facebook_authentication

    if params[:email].blank?
      render :status => 400,
              :json => {:status=>"Failure",:message=>"Email Address is required"}
       return
    end

    if params[:uid].blank?
      render :status => 400,
              :json => {:status=>"Failure",:message=>"UID is required"}
       return
    end
    if params[:access_token].blank?
      render :status => 400,
              :json => {:status=>"Failure",:message=>"Access Token is required"}
       return
    end
    
    @user = User.where(:email => params[:email]).first
    if !@user.present?
      @user = User.new(
            :provider => "facebook",
            :uid => params[:uid],
            :email => params[:email],
            :password => Devise.friendly_token[0,20],
            :authentication_token => params[:access_token],
          )
      if @user.save
        @token = @user.ensure_authentication_token
        sign_in @user, store: true
        render :status=>200, :json=>{ :status=>"Success",
                :key=>@user.key,
                :authentication_token => @token.token,
                :user_name => @user.user_name,
                :email => @user.email,
                :message => "Registeration Success."}
      else
        logger.info @user.errors.inspect
        render :status => 200, :json=>{ :status=>"Failure",:message=>"Registeration Failed Error: #{@user.errors.full_messages.join(", ")}."}
      end
    else
      @user.authentication_token = params[:access_token]
      @user.uid = params[:uid] if params[:uid].present?
      if @user.save
        @token = @user.ensure_authentication_token
        sign_in @user, store: true
        render :status=>200, :json=>{:status=>"Success",:authentication_token=>@token.token,:key=>@user.key,:user_id => @user.id}      
      else
        logger.info @user.errors.inspect
        render :status=>200, :json=>{ :status=>"Failure",:message=>"Login Failed Error: #{@user.errors.full_messages.join(", ")}."}
      end 
    end
  end

  def destroy_token
    key = params[:key].presence
    user = key && User.find_by_key(key)
    if user.nil?
      render :status=>401, :json=>{:status=>"Failure",:message=>"Invalid Key."}
      return
    end
   
    if user
      token = user.access_tokens.where(:token => params[:authentication_token])
      token.destroy_all
      render :status=>200, :json=>{:status=>"Success",:message=>"Authentication token set to nil"}
    else
      render :status=>401, :json=>{:status=>"Failure",:message=>"Invalid Authentication token."}
      return
    end
  end
   
end
