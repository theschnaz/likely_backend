class SessionsController < ApplicationController 
  protect_from_forgery :except => [:new_user]
  protect_from_forgery :except => [:new_user_email]
   
  def new_user
    #created via the app
    uid = params[:uid]
    key = params[:key]
    
    unless User.find_by_uid(uid)
      user_data = FbGraph2::User.new(uid).authenticate(key)
      user_data = user_data.fetch(fields: [:name,:email,:gender,:timezone])
      user = User.new
      user.name = user_data.name
      user.facebook_key = params[:key]
      user.email = user_data.email
      user.fb_pic_square = 'http://graph.facebook.com/' + user_data.id + '/picture?type=square'
      user.fb_pic_large = 'http://graph.facebook.com/' + user_data.id + '/picture?type=large'
      user.provider = 'facebook'
      user.uid = user_data.id
      user.save
    end
    
    #if the user already exits, they are sent here becuase of a FB token issue, update token here
    if User.find_by_uid(uid)
      user = User.find_by_uid(uid)
      user.facebook_key = params[:key]
      user.save
    end
    
    render :text => user.name
  end
  
  def new_user_email
  
    user = User.find_by_sql("select * from users where email address = " + params[:email] + " and password = " + params[:password])
  
    if user
      render :text => 'user exists' and return
    else
      render :text => 'user does not exist' and return
    end
  
  end
end
