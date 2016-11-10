class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    puts "!!!My params: #{params.inspect}"
    @user = User.new(user_params) 
    puts "This is user: #{@user.inspect}"
    if @user.save
      redirect_to new_user_path
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    puts "!!!My params: #{params.inspect}"
    @user = User.find(params[:id]) 
    puts "This is user: #{@user.inspect}"
    if @user.update(user_params)
      redirect_to edit_user_path
    else
      render :edit
    end
  end

  

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

end
