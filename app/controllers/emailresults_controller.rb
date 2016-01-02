class EmailresultsController < ApplicationController
	def sendresults
	  #duels that have been voted on yesterday
	  duels = Snap.find_by_sql("select snaps.id, snaps.snapped_by, snaps.photo_url, snaps.vote_left, snaps.vote_right from snaps, votes where snaps.id = votes.snap_id and votes.updated_at >= current_date - interval '1 day'")
	  
	  duels.each do |p|
	  
	    user = User.find_by_sql("select users.email from users, snaps where snaps.snapped_by = users.id and snaps.id = " + p.id.to_s)
	    user = user.first
	    
	    p.vote_right = Vote.where(:snap_id => p.id, :vote => 'right').count
      	p.vote_left = Vote.where(:snap_id => p.id, :vote => 'left').count
      	total = p.vote_right + p.vote_left
      	
      	rightpercent = ((p.vote_right.to_f/total.to_f)*100).round
      	leftpercent = ((p.vote_left.to_f/total.to_f)*100).round
	  
	    client = SendGrid::Client.new(api_user: 'theschnaz', api_key: '33sendflop')
	      mail = SendGrid::Mail.new do |m|
	      m.to = user.email
	      m.from = 'LikelyUpdates@likely.com'
	      m.subject = 'Update on your pic!'
	      m.html = leftpercent.to_s + '% like the left and ' + rightpercent.to_s + '% like the right! ' + total.to_s + ' people have voted. <br /><br /> <img src="' + p.photo_url.to_s + '" style = "max-width:400px;" />'
	      m.text = "Image uploaded"
	    end
	   puts client.send(mail)
	  
	  end
	  
	  render :text => "sent"
	end
	
	def newandtrending
	  
	  #pics created in the last day
	  duels = Snap.find_by_sql("select snaps.id, snaps.snapped_by, snaps.photo_url, snaps.question from snaps where snaps.created_at >= current_date - interval '100 day'")
	  
	  #users
	  users = User.find_by_sql("select * from users")
	
	  #add a loop here for all users, only sending to theschnaz@gmail.com for now
	  
	  url_html = '<table style="width:800px"> <img src="https://dl.dropboxusercontent.com/u/63975/logo_1024.png" style="width:800px" /> <br />'
	  
	  #builds the image URLs + html
	  duels.each do |d|
	    url_html += 'Which is likely ' + d.question.to_s + '? <br /> <img src="' + d.photo_url.to_s + '" /> ' + '<br /> <br />'
	  end
	  
	  client = SendGrid::Client.new(api_user: 'theschnaz', api_key: '33sendflop')
	  	mail = SendGrid::Mail.new do |m|
	  	m.to = "theschnaz@gmail.com"
	    m.from = 'LikelyNewAndTrending@likely.com'
	    m.subject = 'New and trending pics on Likely!'
	    m.html = url_html
	    m.text = "Please use email that supports HTML. We're trying to show you pics!"
	  end
	  
	  url_html += '</table>'
	  
	  puts client.send(mail)
	  
	  render :text => "sent"
	
	end

	
end
