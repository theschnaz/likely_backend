class SessionsController < ApplicationController 
  protect_from_forgery :except => [:new_user]
   
  def new_user
    #created via the app
    uid = params[:uid]
    key = params[:key]
    
    unless User.find_by_uid(uid)
     user_data = FbGraph2::User.new(uid).authenticate(key)
     user_data.fetch
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
      user.find_by_uid(uid)
      user.facebook_key = params[:key]
      user.save
    end
    
    render :text => user.name
  end
end
