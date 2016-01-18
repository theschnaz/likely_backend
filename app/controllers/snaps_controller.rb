class SnapsController < ApplicationController 
  protect_from_forgery :except => [:new_snap, :new_share_photo, :flag_pic]
  
  def new_share_photo
    data = Cloudinary::Uploader.upload(params[:photo])
    render json: data
  end
  
  def flag_pic
  	#this seems like overkill, but oh well...
  	
  	flag_id = params[:snap_id]
  	
    client = SendGrid::Client.new(api_user: 'theschnaz', api_key: '33sendflop')
  	mail = SendGrid::Mail.new do |m|
	  m.to = "theschnaz@gmail.com"
	  m.from = 'flag@likely.com'
	  m.subject = 'Someone flagged a pic'
	  m.text = "id = " + flag_id.to_s
	end
	puts client.send(mail)
	
	render :text => "pic flagged"
  
  end
 
  def new_snap
  	user = User.find_by_uid(params[:uid])
  
    ##require 'sendgrid-ruby'
  		
    snap = Snap.new
    snap.save
    #need to save here to get the snap ID for the next line
    snap.photo_url = 'http://res.cloudinary.com/hh55qpw1c/image/upload/w_500,h_500,c_fill/v1419546151/' + snap.id.to_s + '.jpg'
    snap.snapped_by = user.id
    snap.category = params[:category]
    
    
    if(snap.save)
	    client = SendGrid::Client.new(api_user: 'theschnaz', api_key: '33sendflop')
	  	mail = SendGrid::Mail.new do |m|
		  m.to = user.email
		  m.from = 'Likely@likely.com'
		  m.subject = 'You posted a pic!'
		  m.html = 'When people vote on your pic, we\'ll let you know, good luck!<br /><br /> <img src="' + snap.photo_url + '" style="max-width:400px;" />'
		  m.text = "Image uploaded"
		end
		puts client.send(mail)
		
    end
    
  
    Cloudinary::Uploader.upload(params[:photo], :public_id => snap.id)
    
    
    
    render :text => snap.photo_url.to_s
  end
  
  def get_snap
    user = User.find_by_uid(params[:uid])
    snapdata = Snap.find_by_sql("select id, snapped_by, photo_url, vote_right, vote_left, left_text, right_text, question, category from snaps where id NOT IN (select snap_id from votes where user_id =" + user.id.to_s + ") order by id desc")
   
    
    ##this gets a little wonky if the snap_id in the votes table is blank

    if snapdata.size > 1
      ##this gets a little wonky if the snap_id in the votes table is blank
      
      
      #this can't be a good solution, but I need to know how many images are in each category that the member hasn't voted on yet
      animals = 0
      art = 0
      people = 0
      food = 0
      music = 0
      
      snap = snapdata.first
      
      snapdata.each do |x|
        if x.category == 'animals'
          animals += 1
        end
        if x.category == 'art'
          art += 1
        end
        if x.category == 'people'
          people += 1
        end
        if x.category == 'food'
          food += 1
        end
        if x.category == 'music'
          music += 1
        end     
      end
      
      
      
      
      #if there aren't two images in the category, render done, in the future, we'll need to look for other images
      cat = false
      catcount = 0
      
      while cat == false do      
	    if (snap.category == 'animals') && (animals > 1)
	      snap2 = snapdata[catcount + 1]
	      cat = true
	    elsif (snap.category == 'art')&&(art>1)
	      snap2 = snapdata[catcount + 1]
	      cat = true
	    elsif (snap.category == 'people')&&(people>1)
	      snap2 = snapdata[catcount + 1]
	      cat = true
	    elsif (snap.category == 'food')&&(food>1)
	      snap2 = snapdata[catcount + 1]
	      cat = true
	    elsif (snap.category =='music')&&(music>1)
	      snap2 = snapdata[catcount + 1]
	      cat = true
        else
          catcount += 1
	      snap = snapdata[catcount]
	      
	    end
	  end
      
      i = 1
      
      until snap2.category == snap.category do
        snap2 = snapdata[i]
        i += 1
      end
      
      
      #get the profile imgaes of the posters...   
      user1 = User.find_by_id(snap.snapped_by)
      user2 = User.find_by_id(snap2.snapped_by)
      
    
      if snap.question.nil?
        snap.question = 'better'
      end
      #if null, set to better
      
      puts snap.photo_url.to_s
      
      #snap.vote_right = Vote.where(:snap_id => snap.id, :vote => 'right').count
      #snap.vote_left = Vote.where(:snap_id => snap.id, :vote => 'left').count
      
      render :json => {:snap => snap, :snap2 => snap2, :user => user1, :user2 => user2}
    end
    
    if snapdata.size < 2
      render :text => 'done'
    end
  end
  
  def get_snap_and_vote
  
    user = User.find_by_uid(params[:uid])
    
    vote = Vote.new
    vote.user_id = user.id
    vote.top_id = params[:top]
    vote.bottom_id = params[:bottom]
    
    if params[:vote] == params[:top]
      vote.top_vote = params[:top]
      vote.snap_id = params[:top]
    else
      vote.bottom_vote = params[:bottom]
      vote.snap_id = params[:bottom]
    end
    
    vote.save
    
    snapdata = Snap.find_by_sql("select id, snapped_by, photo_url, vote_right, vote_left, left_text, right_text, question, category from snaps where id NOT IN (select snap_id from votes where user_id =" + user.id.to_s + ") order by id desc")
   
    
    ##this gets a little wonky if the snap_id in the votes table is blank

    if snapdata.size > 1
      
      
      #this can't be a good solution, but I need to know how many images are in each category that the member hasn't voted on yet
      animals = 0
      art = 0
      people = 0
      food = 0
      music = 0
      
      snapdata.each do |x|
        if x.category == 'animals'
          animals += 1
        end
        if x.category == 'art'
          art += 1
        end
        if x.category == 'people'
          people += 1
        end
        if x.category == 'food'
          food += 1
        end
        if x.category == 'music'
          music += 1
        end
        
      end
      
      
      snap = snapdata.first
      
      #if there aren't two images in the category, render done, in the future, we'll need to look for other images
      cat = false
      catcount = 0
      
      while cat == false do      
	    if (snap.category == 'animals') && (animals > 1)
	      snap2 = snapdata[catcount + 1]
	      cat = true
	    elsif (snap.category == 'art')&&(art>1)
	      snap2 = snapdata[catcount + 1]
	      cat = true
	    elsif (snap.category == 'people')&&(people>1)
	      snap2 = snapdata[catcount + 1]
	      cat = true
	    elsif (snap.category == 'food')&&(food>1)
	      snap2 = snapdata[catcount + 1]
	      cat = true
	    elsif (snap.category =='music')&&(music>1)
	      snap2 = snapdata[catcount + 1]
	      cat = true
        else
          catcount += 1
	      snap = snapdata[catcount]
	      
	    end
	  end
      
      
      i = 1
      
      until snap2.category == snap.category do
        snap2 = snapdata[i]
        i += 1
      end
      
      #get the profile imgaes of the posters...   
      user1 = User.find_by_id(snap.snapped_by)
      user2 = User.find_by_id(snap2.snapped_by)
    
      if snap.question.nil?
        snap.question = 'better'
      end
      #if null, set to better
      
      puts snap.photo_url.to_s
      
      #snap.vote_right = Vote.where(:snap_id => snap.id, :vote => 'right').count
      #snap.vote_left = Vote.where(:snap_id => snap.id, :vote => 'left').count
      
      render :json => {:snap => snap, :snap2 => snap2, :user => user1, :user2 => user2}
    end
    
    #need at least two snaps
    if snapdata.size < 2
      render :text => 'done'
    end
  end
  
end
