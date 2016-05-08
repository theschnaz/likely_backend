class SnapsController < ApplicationController 
  protect_from_forgery :except => [:new_snap, :new_share_photo, :flag_pic]

  def show

    @snap = Snap.find(params[:id])

    @url_html = '<meta property="og:image" content="' + @snap.photo_url.to_s + '" />'

    @url_html += '<table style="width:500px;"> <tr><td> <img src="https://dl.dropboxusercontent.com/u/63975/email_logo.png" style="width:500px" /> </td></tr><br />'

    othersnaps = Vote.connection.select_all("select top_vote, bottom_vote from votes where (top_id = " + @snap.id.to_s + " or bottom_id = " + @snap.id.to_s + ") and (top_vote != " + @snap.id.to_s + " or bottom_vote != " + @snap.id.to_s + ")")

    othersnapsarray = Array.new

      r = 0
      while(r < othersnaps.count)
        if(othersnaps[r]['top_vote'].nil?)
          othersnapsarray << othersnaps[r]['bottom_vote']
        else
          othersnapsarray << othersnaps[r]['top_vote']
        end
        r = r + 1
      end

      othersnapsarray = othersnapsarray.uniq

      betterthan = Array.new
      worsethan = Array.new

      othersnapsarray.each do |x|
        thisimagevotes = Vote.connection.select_all("select id from votes where (top_vote = " + @snap.id.to_s + " or bottom_vote = " + @snap.id.to_s + ") and ((top_id = " + @snap.id.to_s + " or bottom_id =" + x.to_s + ") or (top_id = " + x.to_s + " and bottom_id =" + @snap.id.to_s + "))")
        thisimagevotes = thisimagevotes.count

        thatimagevotes = Vote.connection.select_all("select id from votes where (top_vote = " + x.to_s + " or bottom_vote = " + x.to_s + ") and ((top_id = " + @snap.id.to_s + " or bottom_id = " + x.to_s + ") or (top_id = " + x.to_s + " and bottom_id =" + @snap.id.to_s + "))")
        thatimagevotes = thatimagevotes.count

        if(thisimagevotes > thatimagevotes)
          worsethan << x
        else
          betterthan << x
        end
      end


      @url_html += '<tr><td><br /><br /></td></tr>'
      @url_html += '<tr><td><strong style="font-size:24px;">Which is likely better or worse? <br /><img src="' + @snap.photo_url.to_s + '" style="width:500px;"/> ' + '</td></tr><br/>'
      @url_html += '<tr><td><br /><br /></td></tr>'
      @url_html += '<tr><td><strong>Likely better</strong></td></tr>'
      @url_html += '<tr><td>'
      betterthan.each do |x|
        @url_html += '<a href="/snaps/' + x.to_s + '"><img src = "http://res.cloudinary.com/hh55qpw1c/image/upload/w_500,h_500,c_fill/v1419546151/' + x.to_s + '.jpg" style="width:100px;" /></a>'
      end
      @url_html += '</td></tr><br />'
      @url_html += '<tr><td><br /><br /></td></tr>'
      @url_html += '<tr><td><strong>Likely worse</strong></td></tr>'
      @url_html += '<tr><td>'
      worsethan.each do |x|
        @url_html += '<a href="/snaps/' + x.to_s + '"><img src = "http://res.cloudinary.com/hh55qpw1c/image/upload/w_500,h_500,c_fill/v1419546151/' + x.to_s + '.jpg" style="width:100px;" /></a>'
      end
      @url_html += '</td></tr>'
      @url_html += '<tr ><td style="border-top: 5px solid #cccccc;"><br /><br /></td></tr>'
      @url_html += '<tr><td><br /><br /></td></tr>'

      @url_html += '<tr><td><strong style="font-size:24px;">Share Likely with a friend!  <a href="https://itunes.apple.com/app/which-is-likely-better/id1035137555?mt=8">iOS</a> and <a href="https://play.google.com/store/apps/details?id=com.likely">Android</a></strong><br /><br /></td></tr>'

      @url_html += '</table>'


      render html: @url_html.html_safe

  end
  
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
  	
  	#if the user didnt connect FB, dont post photo
  	if user.facebook_key == ''
  	  render :text => 'no photo' and return
  	end
  
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
    snapdata = Snap.find_by_sql("select id, snapped_by, photo_url, vote_right, vote_left, left_text, right_text, question, category from snaps where id NOT IN (select snap_id from votes where user_id =" + user.id.to_s + ") order by id asc")
   
    
    ##this gets a little wonky if the snap_id in the votes table is blank

    if snapdata.size > 5
      ##this gets a little wonky if the snap_id in the votes table is blank
      
      
      #this can't be a good solution, but I need to know how many images are in each category that the member hasn't voted on yet
      animals = 0
      art = 0
      people = 0
      food = 0
      
      snap = snapdata.first
      snap2 = snapdata.first
      
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
        else
          catcount += 1
          
          puts catcount
	      
	      if catcount == 4 #the total number of categories
	        puts "rendered done"
            render :text => 'done' and return
          else
	        snap = snapdata[catcount]
	      end
	      
	    end
	  end
      
      i = 1
      
      while snap2.category != snap.category do
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
      
      puts user2.fb_pic_square
      
      #votes for top image

      snap1_top_votes = Vote.count_by_sql "select count(*) from votes where top_id = " + snap.id.to_s + " and bottom_id = " + snap2.id.to_s + " and top_vote =" + snap.id.to_s
      snap1_bottom_votes = Vote.count_by_sql "select count(*) from votes where top_id = "+ snap2.id.to_s + " and bottom_id = " + snap.id.to_s + " and bottom_vote = " + snap.id.to_s
      snap1_votes = snap1_top_votes + snap1_bottom_votes

      snap2_top_votes = Vote.count_by_sql "select count(*) from votes where top_id = " + snap2.id.to_s + " and bottom_id = " + snap.id.to_s + " and top_vote =" + snap2.id.to_s
      snap2_bottom_votes = Vote.count_by_sql "select count(*) from votes where top_id = "+ snap.id.to_s + " and bottom_id = " + snap2.id.to_s + " and bottom_vote = " + snap2.id.to_s
      snap2_votes = snap2_top_votes + snap2_bottom_votes

      
      render :json => {:snap => snap, :snap2 => snap2, :user => user1, :user2 => user2, :snap1votes => snap1_votes, :snap2votes => snap2_votes}
    end
    
    if snapdata.size < 6
      render :text => 'done'
    end
  end
  
  def get_snap_and_vote

    puts "in get_snap_and_vote"

    user = User.find_by_uid(params[:uid])
    #do the vote stuff if there is a vote (top)
    if(params[:top])
      
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
      
      #if the click came from a guest, don't save anything
      unless params[:uid] == '1217683588257786'
        vote.save
      end
    end

    
    
    allsnaps = Snap.connection.select_all("select t1.id as id1, t2.id as id2, t1.category from snaps as t1 cross join snaps as t2 where t1.id != t2.id and t1.category = t2.category")
    snap = 0
    snap2 = 0

    max = 0
    allsnaps.each do 
      max = max + 1
    end

    max = max - 1 #remove 1 since allsnaps starts at 0
    #max = the number of pairs

    while(max > 0)
      
      pair = rand(0..max)
      
      snappair = allsnaps[pair]
      
      combovote = Vote.find_by_sql("select id from votes where (top_id = " + snappair['id1'].to_s + " and bottom_id = " + snappair['id2'].to_s + " and user_id = " + user.id.to_s + ") or (top_id = " + snappair['id2'].to_s + " and bottom_id = " + snappair['id1'].to_s + " and user_id = " + user.id.to_s + ")")
      
      if(combovote.size == 0 && (snappair['id1'] != snappair['id2']))
        snap2 = Snap.find_by_id(snappair['id2'])
        snap = Snap.find_by_id(snappair['id1'])
        break
      end

      max = max -1
    end

    if(max == 0)
      render :text => 'done' and return
    end

    puts "after big while"
      
      
      
    #get the profile imgaes of the posters...   
    user1 = User.find_by_id(snap.snapped_by)
    user2 = User.find_by_id(snap2.snapped_by)
  
    
    puts snap.photo_url.to_s
    
    snap1_top_votes = Vote.count_by_sql "select count(*) from votes where top_id = " + snap.id.to_s + " and bottom_id = " + snap2.id.to_s + " and top_vote =" + snap.id.to_s
    snap1_bottom_votes = Vote.count_by_sql "select count(*) from votes where top_id = "+ snap2.id.to_s + " and bottom_id = " + snap.id.to_s + " and bottom_vote = " + snap.id.to_s
    snap1_votes = snap1_top_votes + snap1_bottom_votes

    snap2_top_votes = Vote.count_by_sql "select count(*) from votes where top_id = " + snap2.id.to_s + " and bottom_id = " + snap.id.to_s + " and top_vote =" + snap2.id.to_s
    snap2_bottom_votes = Vote.count_by_sql "select count(*) from votes where top_id = "+ snap.id.to_s + " and bottom_id = " + snap2.id.to_s + " and bottom_vote = " + snap2.id.to_s
    snap2_votes = snap2_top_votes + snap2_bottom_votes

    
    render :json => {:snap => snap, :snap2 => snap2, :user => user1, :user2 => user2, :snap1votes => snap1_votes, :snap2votes => snap2_votes}
  
  end
end
