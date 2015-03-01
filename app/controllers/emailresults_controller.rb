class EmailresultsController < ApplicationController
	def sendresults
	  #duels that have been voted on yesterday
	  duels = Snap.find_by_sql("select snaps.id, snaps.snapped_by, snaps.photo_url, snaps.vote_left, snaps.vote_right from snaps, votes where snaps.id = votes.snap_id and votes.updated_at >= current_date - interval '1 day'")
	  
	  duels.each do |p|
	  
	    user = User.find_by_sql("select * from users, snaps where snaps.snapped_by = users.id and snaps.id = ?", p.id)
	  
	    client = SendGrid::Client.new(api_user: 'theschnaz', api_key: '33floppyq')
	      mail = SendGrid::Mail.new do |m|
	      m.to = user.email
	      m.from = 'SnapBot@likely.com'
	      m.subject = 'Update on your duel!'
	      m.html = 'Left = ' + p.vote_left + ' Right = ' + p.vote_right + ' <br /> <img src="' + p.photo_url + '" style = "max-width:400px;" />'
	      m.text = "Image uploaded"
	   end
	   puts client.send(mail)
	  
	  end
	  
	  render :text => "sent"
	end

	
end
