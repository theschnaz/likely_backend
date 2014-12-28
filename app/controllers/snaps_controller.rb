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
  
  def get_snap
    snap = Snap.find_by_id(rand(4..6))
    render :text => 'http://res.cloudinary.com/hh55qpw1c/image/upload/v1419546151/' + snap.id.to_s + '.jpg'
  end
  
  def get_snap_and_vote
    snap = Snap.find_by_id(rand(4..6))
    render :text => 'http://res.cloudinary.com/hh55qpw1c/image/upload/v1419546151/' + snap.id.to_s + '.jpg'
  end
  
end
