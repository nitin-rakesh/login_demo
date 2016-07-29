class PostsController < ApplicationController

  before_filter :authenticate_user!
  before_action :find_post, :only => [:show, :edit, :update, :destroy]

  def index
    @posts = Post.all
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    if @post.save
      Picture.create(:picturable_id=>@post.id,:picturable_type=>params[:picturable_type],:image=>params[:image])
      redirect_to posts_path
    else
      render 'new'
    end
  end

  def show
    
  end

  def edit
  end

  def update
    if @post.update_attributes(post_params)
      redirect_to posts_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path
  end

  protected

  def find_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit!
  end

end
