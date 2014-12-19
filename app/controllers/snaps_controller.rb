class SnapsController < ApplicationController 
  protect_from_forgery :except => [:new_snap]
 
  def new_snap
    Cloudinary::Uploader.upload(params[:photo])
  end
end
