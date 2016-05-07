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
	  duels = Vote.connection.select_all("select distinct votes.snap_id, snaps.photo_url from votes, snaps where votes.created_at > CURRENT_DATE - interval '1 day' and snaps.id=votes.snap_id order by votes.snap_id desc")
	  
	  #users
	  users = User.find_by_sql("select * from users where email is not null")
	
	  
	  
	  
	  users.each do |g|
	  	  #add a loop here for all users, only sending to theschnaz@gmail.com for now
	  	  url_html = '<table style="width:500px;"> <tr><td> <img src="https://dl.dropboxusercontent.com/u/63975/email_logo.png" style="width:500px" /> </td></tr><br />'

		  #builds the image URLs + html
		  i = 0
		  while(i < duels.count)
		  	#this code helps us find the other snap ids that this snap has been compared to
		  	othersnaps = Vote.connection.select_all("select top_vote, bottom_vote from votes where (top_id = " + duels[i]['snap_id'].to_s + " or bottom_id = " + duels[i]['snap_id'].to_s + ") and (top_vote != " + duels[i]['snap_id'].to_s + " or bottom_vote != " + duels[i]['snap_id'].to_s + ")")
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
				thisimagevotes = Vote.connection.select_all("select id from votes where (top_vote = " + duels[i]['snap_id'].to_s + " or bottom_vote = " + duels[i]['snap_id'].to_s + ") and ((top_id = " + duels[i]['snap_id'].to_s + " or bottom_id =" + x.to_s + ") or (top_id = " + x.to_s + " and bottom_id =" + duels[i]['snap_id'].to_s + "))")
				thisimagevotes = thisimagevotes.count

				thatimagevotes = Vote.connection.select_all("select id from votes where (top_vote = " + x.to_s + " or bottom_vote = " + x.to_s + ") and ((top_id = " + duels[i]['snap_id'].to_s + " or bottom_id = " + x.to_s + ") or (top_id = " + x.to_s + " and bottom_id =" + duels[i]['snap_id'].to_s + "))")
				thatimagevotes = thatimagevotes.count

				if(thisimagevotes >= thatimagevotes)
					betterthan << x
				else
					worsethan << x
				end
			end

			if(betterthan.size >0 && worsethan.size >0 )
				puts "count = " + i.to_s + " "

				url_html += '<tr><td><strong style="font-size:16px;">Which is likely better or worse? <br /><img src="' + duels[i]['photo_url'].to_s + '" style="width:300px;"/> ' + '</td></tr><br/>'
				url_html += '<tr><td><strong>Likely better</strong></td></tr>'
				url_html += '<tr><td>'
				betterthan.each do |x|
					url_html += '<img src = "http://res.cloudinary.com/hh55qpw1c/image/upload/w_500,h_500,c_fill/v1419546151/' + x.to_s + '.jpg" style="width:100px;" />'
				end
				url_html += '</td></tr><br />'
				url_html += '<tr><td><strong>Likely worse</strong></td></tr>'
				url_html += '<tr><td>'
				worsethan.each do |x|
					url_html += '<img src = "http://res.cloudinary.com/hh55qpw1c/image/upload/w_500,h_500,c_fill/v1419546151/' + x.to_s + '.jpg" style="width:100px;" />'
				end
				url_html += '</td></tr>'
				url_html += '<tr ><td style="border-top: 5px solid #cccccc;"><br /><br /></td></tr>'
				url_html += '<tr><td><br /><br /></td></tr>'

			end

			i = i + 1
		  end

		  client = SendGrid::Client.new(api_user: 'theschnaz', api_key: '33sendflop')
	  	  mail = SendGrid::Mail.new do |m|
	  	    m.to = "theschnaz@gmail.com"
	        m.from = 'LikelyNewAndTrending@likely.com'
	        m.subject = 'New and trending pics on Likely!'
	        m.html = url_html
	        m.text = "Please use email that supports HTML. We're trying to show you pics!"
	      end

		  url_html += '<tr><td><strong>Share Likely with a friend!  <a href="https://itunes.apple.com/app/which-is-likely-better/id1035137555?mt=8">iOS</a> and <a href="https://play.google.com/store/apps/details?id=com.likely">Android</a></strong></td></tr>'
	      url_html += '</table>'

		  puts client.send(mail)
		  
		  puts "sent to: " + g.email

		  url_html = ''
	  end
	  render :text => "sent"
	end	
end
