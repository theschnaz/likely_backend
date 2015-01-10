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
    user = User.find_by_uid(params[:uid])
    snap = Snap.find_by_sql("select id from snaps where id NOT IN (select snap_id from votes where user_id =" + user.id.to_s + ")")
    snap = snap.first
    if(snap)
      render :text => 'http://res.cloudinary.com/hh55qpw1c/image/upload/v1419546151/' + snap.id.to_s + '.jpg'
    else
      render :text => 'done'
    end
  end
  
  def get_snap_and_vote
    user = User.find_by_uid(params[:uid])
    
    vote = Vote.new
    vote.user_id = user.id
    snap_id = params[:snap_url]
    #this little beauty finds the ID from the URL
    vote.snap_id = snap_id[61...-4]
    vote.vote = params[:vote]
    vote.save
    
    ##calculate the votes and return a percent
    #left = Vote.find_by_sql("select count(id) from votes where vote = 'left' and snap_id = " + snap_id.to_s
    left = Vote.where(snap_id: snap_id, vote: "left")
    right = Vote.where(snap_id: snap_id, vote: "left")
    total_votes = left + right
    
    if(left > right)
      final_vote = (left/(left+right)).to_s + " left")
    end
    if(right > left)
      final_vote = right/(left+right).to_s + " right")
    end
    if(left == right)
      final_vote = "even"
    end
    
    
    snap = Snap.find_by_sql("select id from snaps where id NOT IN (select snap_id from votes where user_id =" + user.id.to_s + ")")
    snap = snap.first
    
    if(snap)
      render :text => 'http://res.cloudinary.com/hh55qpw1c/image/upload/v1419546151/' + snap.id.to_s + '.jpg'
    else
      render :text => 'done'
    end
  end
  
end
