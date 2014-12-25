class SnapsController < ApplicationController 
  protect_from_forgery :except => [:new_snap]
 
  def new_snap
    snap = Snap.new
    snap.save
    snap.photo_url = 'http://res.cloudinary.com/hh55qpw1c/image/upload/v1419546151/' + snap.id.to_s + '.jpg'
    snap.save
    
  
    Cloudinary::Uploader.upload(params[:photo], :public_id => snap.id)
    
    
    
    render :text => "uploaded"
  end
end
