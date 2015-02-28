class SnapsController < ApplicationController 
  protect_from_forgery :except => [:new_snap]
 
  def new_snap
  	user = User.find_by_uid(params[:uid])
  
    ##require 'sendgrid-ruby'
  		
    snap = Snap.new
    snap.save
    #need to save here to get the snap ID for the next line
    snap.photo_url = 'http://res.cloudinary.com/hh55qpw1c/image/upload/a_90,w_500,h_500,c_fill/v1419546151/' + snap.id.to_s + '.jpg'
    if(snap.save)
	    client = SendGrid::Client.new(api_user: 'theschnaz', api_key: '33floppyq')
	  	mail = SendGrid::Mail.new do |m|
		  m.to = user.email
		  m.from = 'SnapBot@likely.com'
		  m.subject = 'You posted a Snap!'
		  m.html = 'When people swipe on your Snap, we\'ll let you know!<br /><br /> <img src="' + snap.photo_url + '" style="max-width:400px;" />'
		  m.text = "Image uploaded"
		end
		puts client.send(mail)
    end
    
  
    Cloudinary::Uploader.upload(params[:photo], :public_id => snap.id)
    
    
    
    render :text => "uploaded"
  end
  
  def get_snap
    user = User.find_by_uid(params[:uid])
    snap = Snap.find_by_sql("select id, photo_url from snaps where id NOT IN (select snap_id from votes where user_id =" + user.id.to_s + ")")
    ##this gets a little wonky if the snap_id in the votes table is blank
    snap = snap.first
    if(snap)
      puts snap.photo_url.to_s
      render :text => snap.photo_url.to_s
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
    left = Vote.where(snap_id: snap_id, vote: "left").count
    right = Vote.where(snap_id: snap_id, vote: "right").count
    total_votes = left + right
    
    if(left > right)
      final_vote = ((left.to_f/(left.to_f+right.to_f))*100).round
      final_vote = "L" + final_vote.to_s
    end
    if(right > left)
      final_vote = ((right.to_f/(left.to_f+right.to_f))*100).round
      final_vote = "R" + final_vote.to_s
    end
    if((left == right) && (left == 0))
      final_vote = "F"
    end
    if(left == right)
      final_vote = "E"
    end
    #by here, we have the percent with an R or L, it's being added to the string returned, the app will have to split the string
    
    
    snap = Snap.find_by_sql("select id from snaps where id NOT IN (select snap_id from votes where user_id =" + user.id.to_s + ")")
    snap = snap.first
    
    if(snap)
      render :text => final_vote + snap.photo_url.to_s
    else
      render :text => 'done'
    end
  end
  
end
