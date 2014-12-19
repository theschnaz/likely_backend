class SnapsController < ApplicationController  
  def new_snap
    Cloudinary::Uploader.upload(params[:photo])
  end
end
