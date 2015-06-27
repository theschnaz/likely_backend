class EmailresultsController < ApplicationController
	def sendresults
	  #duels that have been voted on yesterday
	  #duels = Snap.find_by_sql("select snaps.id, snaps.snapped_by, snaps.photo_url, snaps.vote_left, snaps.vote_right from snaps, votes where snaps.id = votes.snap_id and votes.updated_at >= current_date - interval '1 day'")
	  
	  duels = Snap.find_by_sql("select snaps.id, snaps.snapped_by, snaps.photo_url, snaps.vote_left, snaps.vote_right from snaps, votes where snaps.id = votes.snap_id")
	  
	  duels.each do |p|
	  
	    user = User.find_by_sql("select users.email from users, snaps where snaps.snapped_by = users.id and snaps.id = " + p.id.to_s)
	    user = user.first
	    
	    p.vote_right = Vote.where(:snap_id => p.id, :vote => 'right').count
      	p.vote_left = Vote.where(:snap_id => p.id, :vote => 'left').count
      	total = p.vote_right + p.vote_left
      	
      	rightpercent = (p.vote_right.to_f/total.to_f)*100
      	leftpercent = (p.vote_left/total)*100
	  
	   # client = SendGrid::Client.new(api_user: 'theschnaz', api_key: '33floppyq')
	   #   mail = SendGrid::Mail.new do |m|
	   #   m.to = user.email
	   #   m.from = 'SnapBot@likely.com'
	   #   m.subject = 'Update on your duel!'
	   #   m.html = leftpercent.to_s + '% like the left and ' + rightpercent.to_s + '% like the right! ' + total.to_s + ' people have voted. <br /><br /> <img src="' + p.photo_url.to_s + '" style = "max-width:400px;" />'
	   #   m.text = "Image uploaded"
	   # end
	   #puts client.send(mail)
	   
	   puts p.vote_right
	   puts total
	   puts rightpercent
	  
	  end
	  
	  render :text => "sent"
	end

	
end
