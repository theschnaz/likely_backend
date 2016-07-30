class EmailresultsController < ApplicationController
	protect_from_forgery :except => [:addtoinvitedfollowers]

	def addtoinvitedfollowers

		persontoadd = InvitedFollowers.new

		persontoadd.email = params[:email]
		persontoadd.snap = params[:snap]

		persontoadd.save

		render :text => "saved" and return

	end

	def invitedfollowers

	  #invited followers
	  users = InvitedFollowers.find_by_sql("select * from invited_followers where email is not null")

	  puts 'users.count = ' + users.count.to_s
	
	  url_html = ''
	  
	  
	  users.each do |g|
	  	  #my snaps that were voted on yesterday that the invited person follows
		  #duels = Vote.connection.select_all("select distinct votes.snap_id, snaps.photo_url, snaps.category from votes, snaps where votes.created_at > CURRENT_DATE - interval '1 day' and snaps.id = votes.snap_id and snaps.id in (select distinct snap from invited_followers where email = '" + g.email.to_s + "') order by votes.snap_id desc")
		  duels = Vote.connection.select_all("select distinct votes.snap_id, snaps.photo_url, snaps.category from votes, snaps where votes.created_at > CURRENT_DATE - interval '60 day' and snaps.id = votes.snap_id and snaps.id in (select distinct snap from invited_followers where email = '" + g.email.to_s + "') order by votes.snap_id desc")
		  
		  puts 'g email = ' + g.email.to_s
		  puts 'duels.count = ' + duels.count.to_s

		  if(duels.count == 0)
		  	render :text => "no new votes" and return
		  end

	  	  puts "email for: " + g.email
	  	  puts "html = " + url_html
	  	  #add a loop here for all users, only sending to theschnaz@gmail.com for now
	  	  url_html = '<table style="width:500px;"> <tr><td> <img src="https://dl.dropboxusercontent.com/u/63975/email_logo.png" style="width:500px" /> </td></tr><br />'
	  	  url_html += '<tr><td><a href="https://afternoon-citadel-4709.herokuapp.com/open">Open the app</a></td></tr>'

		  #builds the image URLs + html
		  i = 0
		  while(i < duels.count)
		  	puts "i = " + i.to_s
		  	#this code helps us find the other snap ids that this snap has been compared to
		  	othersnaps = Vote.connection.select_all("select top_id, bottom_id from votes where (top_id = " + duels[i]['snap_id'].to_s + " or bottom_id = " + duels[i]['snap_id'].to_s + ")")

		    othersnapsarray = Array.new

		    puts 'othersnaps.count = ' + othersnaps.count.to_s

		      r = 0
		      while(r < othersnaps.count)
		        if(othersnaps[r]['top_id'] == duels[i]['snap_id'].to_s)
		          othersnapsarray << othersnaps[r]['bottom_id']
		        else
		          othersnapsarray << othersnaps[r]['top_id']
		        end
		        r = r + 1
		      end

			othersnapsarray = othersnapsarray.uniq

			betterthan = Array.new
			worsethan = Array.new

			othersnapsarray.each do |x|
				thisimagevotes = Vote.connection.select_all("select id from votes where (top_vote = " + duels[i]['snap_id'].to_s + " or bottom_vote = " + duels[i]['snap_id'].to_s + ") and ((top_id = " + duels[i]['snap_id'].to_s + " and bottom_id =" + x.to_s + ") or (top_id = " + x.to_s + " and bottom_id =" + duels[i]['snap_id'].to_s + "))")
				thisimagevotes = thisimagevotes.count

				thatimagevotes = Vote.connection.select_all("select id from votes where (top_vote = " + x.to_s + " or bottom_vote = " + x.to_s + ") and ((top_id = " + duels[i]['snap_id'].to_s + " and bottom_id = " + x.to_s + ") or (top_id = " + x.to_s + " and bottom_id =" + duels[i]['snap_id'].to_s + "))")
				thatimagevotes = thatimagevotes.count

				#no ties, images need to be better or worse
				if(thisimagevotes > thatimagevotes)
		          worsethan << x
		        end
		        if(thisimagevotes < thatimagevotes)
		          betterthan << x
		        end
			end

			puts 'worse than count = ' + worsethan.count.to_s
	        puts 'better than count = ' + betterthan.count.to_s

	        total_vote_count = worsethan.count + betterthan.count
	        pic_percent = (worsethan.count.to_f / total_vote_count.to_f)*100
	        pic_percent = pic_percent.to_i

     	 	puts '% = ' + pic_percent.to_s

			addedcontent = false #we'll set this to true if we add content

			if(betterthan.size > 0 || worsethan.size > 0 )
				addedcontent = true

				puts "count = " + i.to_s + " "

				url_html += '<tr><td><strong style="font-size:16px;">This is Likely better than ' + pic_percent.to_s + '% in ' + duels[i]['category'].to_s + ' <br /><a href="https://afternoon-citadel-4709.herokuapp.com/snaps/' + duels[i]['snap_id'].to_s + '"><img src="' + duels[i]['photo_url'].to_s + '" style="width:300px;"/></a> ' + '</td></tr><br/>'
				url_html += '<tr><td><strong>These are the better ' + (100 - pic_percent).to_s + '%</strong></td></tr>'
				url_html += '<tr><td>'
				betterthan.each do |x|
					url_html += '<a href="https://afternoon-citadel-4709.herokuapp.com/snaps/' + x.to_s + '"><img src = "http://res.cloudinary.com/hh55qpw1c/image/upload/w_500,h_500,c_fill/v1419546151/' + x.to_s + '.jpg" style="width:100px;" /></a>'
				end
				url_html += '</td></tr><br />'
				url_html += '<tr><td><strong>These are the worse ' + pic_percent.to_s + '%</strong></td></tr>'
				url_html += '<tr><td>'
				worsethan.each do |x|
					url_html += '<a href="https://afternoon-citadel-4709.herokuapp.com/snaps/' + x.to_s + '"><img src = "http://res.cloudinary.com/hh55qpw1c/image/upload/w_500,h_500,c_fill/v1419546151/' + x.to_s + '.jpg" style="width:100px;" /></a>'
				end
				url_html += '</td></tr>'
				url_html += '<tr ><td style="border-top: 5px solid #cccccc;"><br /><br /></td></tr>'
				url_html += '<tr><td><br /><br /></td></tr>'

			end

			i = i + 1
		  end

		  if(addedcontent == false)
		  	render :text => "no new content" and return
		  end

		  url_html += '<tr><td><strong style="font-size:24px;">Share Likely with a friend!  <a href="https://itunes.apple.com/app/which-is-likely-better/id1035137555?mt=8">iOS</a> and <a href="https://play.google.com/store/apps/details?id=com.likely">Android</a></strong><br /><br /></td></tr>'
	      url_html += '</table>'

		  #client = SendGrid::Client.new(api_user: 'theschnaz', api_key: '33sendflop')
	  	  #mail = SendGrid::Mail.new do |m|
	  	  #  m.to = g.email
	  	  #  #m.to = 'theschnaz@gmail.com'
	      #  m.from = 'LikelyUpdates@likely.com'
	      #  m.subject = 'Updates on pics you\'re following on Likely!'
	      #  m.reply_to = 'theschnaz@gmail.com'
	      #  m.html = url_html
	      #  m.text = "Please use email that supports HTML. We're trying to show you pics!"
	      #end

	      url_html = ''
		  #puts client.send(mail)
		  
		  puts "sent to: " + g.email
		  
		  
	  end
	  #render :text => "sent"
	  render html: url_html

	end

	def sendmyresults
	  #results for the pics a member posted
	  #users
	  users = User.find_by_sql("select * from users where email is not null")
	  #users = User.find_by_sql("select * from users where id = 1")
	
	  url_html = ''
	  
	  
	  users.each do |g|
	  	  puts 'g.id.to_s = ' + g.id.to_s 
	  	  #my snaps that were voted on yesterday
		  duels = Vote.connection.select_all("select distinct votes.snap_id, snaps.photo_url, snaps.category from votes, snaps where votes.created_at > CURRENT_DATE - interval '1 day' and snaps.id = votes.snap_id and snaps.snapped_by = " + g.id.to_s + " order by votes.snap_id desc")
		  
		  #if(duels.count == 0)
		  #	render :text => "no new votes" and return
		  #end

	  	  puts "email for: " + g.email
	  	  puts "html = " + url_html
	  	  #add a loop here for all users, only sending to theschnaz@gmail.com for now
	  	  url_html = '<table style="width:500px;"> <tr><td> <img src="https://dl.dropboxusercontent.com/u/63975/email_logo.png" style="width:500px" /> </td></tr><br />'

		  #builds the image URLs + html
		  i = 0

		  addedcontent = false #we'll set this to true if we add content
		  while(i < duels.count)
		  	puts "i = " + i.to_s
		  	#this code helps us find the other snap ids that this snap has been compared to
		  	othersnaps = Vote.connection.select_all("select top_id, bottom_id from votes where (top_id = " + duels[i]['snap_id'].to_s + " or bottom_id = " + duels[i]['snap_id'].to_s + ")")

		    othersnapsarray = Array.new

		    puts 'othersnaps.count = ' + othersnaps.count.to_s

		      r = 0
		      while(r < othersnaps.count)
		        if(othersnaps[r]['top_id'] == duels[i]['snap_id'].to_s)
		          othersnapsarray << othersnaps[r]['bottom_id']
		        else
		          othersnapsarray << othersnaps[r]['top_id']
		        end
		        r = r + 1
		      end

			othersnapsarray = othersnapsarray.uniq

			betterthan = Array.new
			worsethan = Array.new

			othersnapsarray.each do |x|
				thisimagevotes = Vote.connection.select_all("select id from votes where (top_vote = " + duels[i]['snap_id'].to_s + " or bottom_vote = " + duels[i]['snap_id'].to_s + ") and ((top_id = " + duels[i]['snap_id'].to_s + " and bottom_id =" + x.to_s + ") or (top_id = " + x.to_s + " and bottom_id =" + duels[i]['snap_id'].to_s + "))")
				thisimagevotes = thisimagevotes.count

				thatimagevotes = Vote.connection.select_all("select id from votes where (top_vote = " + x.to_s + " or bottom_vote = " + x.to_s + ") and ((top_id = " + duels[i]['snap_id'].to_s + " and bottom_id = " + x.to_s + ") or (top_id = " + x.to_s + " and bottom_id =" + duels[i]['snap_id'].to_s + "))")
				thatimagevotes = thatimagevotes.count

				#no ties, images need to be better or worse
				if(thisimagevotes > thatimagevotes)
		          worsethan << x
		        end
		        if(thisimagevotes < thatimagevotes)
		          betterthan << x
		        end
			end

			puts 'worse than count = ' + worsethan.count.to_s
	        puts 'better than count = ' + betterthan.count.to_s

	        total_vote_count = worsethan.count + betterthan.count
	        pic_percent = (worsethan.count.to_f / total_vote_count.to_f)*100
	        pic_percent = pic_percent.to_i

     	 	puts '% = ' + pic_percent.to_s


			if(betterthan.size >0 || worsethan.size >0 )

				addedcontent = true
				puts "count = " + i.to_s + " "

				url_html += '<tr><td><strong style="font-size:16px;">This is Likely better than ' + pic_percent.to_s + '% in ' + duels[i]['category'].to_s + ' <br /><a href="https://afternoon-citadel-4709.herokuapp.com/snaps/' + duels[i]['snap_id'].to_s + '"><img src="' + duels[i]['photo_url'].to_s + '" style="width:300px;"/></a> ' + '</td></tr><br/>'
				url_html += '<tr><td><strong>These are the better ' + (100 - pic_percent).to_s + '%</strong></td></tr>'
				url_html += '<tr><td>'
				betterthan.each do |x|
					url_html += '<a href="https://afternoon-citadel-4709.herokuapp.com/snaps/' + x.to_s + '"><img src = "http://res.cloudinary.com/hh55qpw1c/image/upload/w_500,h_500,c_fill/v1419546151/' + x.to_s + '.jpg" style="width:100px;" /></a>'
				end
				url_html += '</td></tr><br />'
				url_html += '<tr><td><strong>These are the worse ' + pic_percent.to_s + '%</strong></td></tr>'
				url_html += '<tr><td>'
				worsethan.each do |x|
					url_html += '<a href="https://afternoon-citadel-4709.herokuapp.com/snaps/' + x.to_s + '"><img src = "http://res.cloudinary.com/hh55qpw1c/image/upload/w_500,h_500,c_fill/v1419546151/' + x.to_s + '.jpg" style="width:100px;" /></a>'
				end
				url_html += '</td></tr>'
				url_html += '<tr ><td style="border-top: 5px solid #cccccc;"><br /><br /></td></tr>'
				url_html += '<tr><td><br /><br /></td></tr>'

			end

			i = i + 1
		  end #while(i < duels.count)

		  if(addedcontent == false)
		  	puts 'no email for id = ' + g.id.to_s 
		  else
		    url_html += '<tr><td><strong style="font-size:24px;">Share Likely with a friend!  <a href="https://itunes.apple.com/app/which-is-likely-better/id1035137555?mt=8">iOS</a> and <a href="https://play.google.com/store/apps/details?id=com.likely">Android</a></strong><br /><br /></td></tr>'
	        url_html += '</table>'

		    client = SendGrid::Client.new(api_user: 'theschnaz', api_key: '33sendflop')
	  	    mail = SendGrid::Mail.new do |m|
	  	      m.to = g.email
	  	      #m.to = 'theschnaz@gmail.com'
	          m.from = 'YourPicsOnLikely@likely.com'
	          m.subject = 'Update to pics you posted on Likely!'
	          m.html = url_html
	          m.reply_to = 'theschnaz@gmail.com'
	          m.text = "Please use email that supports HTML. We're trying to show you pics!"
	        end

	        url_html = ''
		    puts client.send(mail)
		  
		    puts "sent to: " + g.email
		  end #closes else
		  
		  
	  end #closes users.each do |g|

	  render :text => "sent"
	end

	
	def newandtrending
	  
	  duels = Vote.connection.select_all("select distinct votes.snap_id, snaps.photo_url, snaps.category from votes, snaps where votes.created_at > CURRENT_DATE - interval '1 day' and snaps.id=votes.snap_id order by votes.snap_id desc")
	  
	  if(duels.count == 0)
	  	render :text => "no new votes" and return
	  end

	  #users
	  users = User.find_by_sql("select * from users where email is not null")
	
	  url_html = ''
	  
	  
	  users.each do |g|
	  	  puts "email for: " + g.email
	  	  puts "html = " + url_html
	  	  #add a loop here for all users, only sending to theschnaz@gmail.com for now
	  	  url_html = '<table style="width:500px;"> <tr><td> <img src="https://dl.dropboxusercontent.com/u/63975/email_logo.png" style="width:500px" /> </td></tr><br />'

		  #builds the image URLs + html
		  i = 0
		  while((i < duels.count) && (i < 6)) #don't need to send more than 5 photos...
		  	puts "i = " + i.to_s
		  	#this code helps us find the other snap ids that this snap has been compared to
		  	othersnaps = Vote.connection.select_all("select top_id, bottom_id from votes where (top_id = " + duels[i]['snap_id'].to_s + " or bottom_id = " + duels[i]['snap_id'].to_s + ")")

		    othersnapsarray = Array.new

		    puts 'othersnaps.count = ' + othersnaps.count.to_s

		      r = 0
		      while(r < othersnaps.count)
		        if(othersnaps[r]['top_id'] == duels[i]['snap_id'].to_s)
		          othersnapsarray << othersnaps[r]['bottom_id']
		        else
		          othersnapsarray << othersnaps[r]['top_id']
		        end
		        r = r + 1
		      end

			othersnapsarray = othersnapsarray.uniq

			betterthan = Array.new
			worsethan = Array.new

			othersnapsarray.each do |x|
				thisimagevotes = Vote.connection.select_all("select id from votes where (top_vote = " + duels[i]['snap_id'].to_s + " or bottom_vote = " + duels[i]['snap_id'].to_s + ") and ((top_id = " + duels[i]['snap_id'].to_s + " and bottom_id =" + x.to_s + ") or (top_id = " + x.to_s + " and bottom_id =" + duels[i]['snap_id'].to_s + "))")
				thisimagevotes = thisimagevotes.count

				thatimagevotes = Vote.connection.select_all("select id from votes where (top_vote = " + x.to_s + " or bottom_vote = " + x.to_s + ") and ((top_id = " + duels[i]['snap_id'].to_s + " and bottom_id = " + x.to_s + ") or (top_id = " + x.to_s + " and bottom_id =" + duels[i]['snap_id'].to_s + "))")
				thatimagevotes = thatimagevotes.count

				#no ties, images need to be better or worse
				if(thisimagevotes > thatimagevotes)
		          worsethan << x
		        end
		        if(thisimagevotes < thatimagevotes)
		          betterthan << x
		        end
			end

			puts 'worse than count = ' + worsethan.count.to_s
	        puts 'better than count = ' + betterthan.count.to_s

	        total_vote_count = worsethan.count + betterthan.count
	        pic_percent = (worsethan.count.to_f / total_vote_count.to_f)*100
	        pic_percent = pic_percent.to_i

     	 	puts '% = ' + pic_percent.to_s

			addedcontent = false #we'll set this to true if we add content

			if(betterthan.size >0 || worsethan.size >0 )

				addedcontent = true
				puts "count = " + i.to_s + " "

				url_html += '<tr><td><strong style="font-size:16px;">This is Likely better than ' + pic_percent.to_s + '% in ' + duels[i]['category'].to_s + ' <br /><a href="https://afternoon-citadel-4709.herokuapp.com/snaps/' + duels[i]['snap_id'].to_s + '"><img src="' + duels[i]['photo_url'].to_s + '" style="width:300px;"/></a> ' + '</td></tr><br/>'
				url_html += '<tr><td><strong>These are the better ' + (100 - pic_percent).to_s + '%</strong></td></tr>'
				url_html += '<tr><td>'
				betterthan.each do |x|
					url_html += '<a href="https://afternoon-citadel-4709.herokuapp.com/snaps/' + x.to_s + '"><img src = "http://res.cloudinary.com/hh55qpw1c/image/upload/w_500,h_500,c_fill/v1419546151/' + x.to_s + '.jpg" style="width:100px;" /></a>'
				end
				url_html += '</td></tr><br />'
				url_html += '<tr><td><strong>These are the worse ' + pic_percent.to_s + '%</strong></td></tr>'
				url_html += '<tr><td>'
				worsethan.each do |x|
					url_html += '<a href="https://afternoon-citadel-4709.herokuapp.com/snaps/' + x.to_s + '"><img src = "http://res.cloudinary.com/hh55qpw1c/image/upload/w_500,h_500,c_fill/v1419546151/' + x.to_s + '.jpg" style="width:100px;" /></a>'
				end
				url_html += '</td></tr>'
				url_html += '<tr ><td style="border-top: 5px solid #cccccc;"><br /><br /></td></tr>'
				url_html += '<tr><td><br /><br /></td></tr>'

			end

			i = i + 1
		  end

		  if(addedcontent == false)
		  	render :text => "no new content" and return
		  end

		  url_html += '<tr><td><strong style="font-size:24px;">Share Likely with a friend!  <a href="https://itunes.apple.com/app/which-is-likely-better/id1035137555?mt=8">iOS</a> and <a href="https://play.google.com/store/apps/details?id=com.likely">Android</a></strong><br /><br /></td></tr>'
	      url_html += '</table>'

		  client = SendGrid::Client.new(api_user: 'theschnaz', api_key: '33sendflop')
	  	  mail = SendGrid::Mail.new do |m|
	  	    #m.to = g.email
	  	    m.to = g.email
	        m.from = 'LikelyNewAndTrending@likely.com'
	        m.subject = 'New and trending pics on Likely!'
	        m.reply_to = 'theschnaz@gmail.com'
	        m.html = url_html
	        m.text = "Please use email that supports HTML. We're trying to show you pics!"
	      end

	      url_html = ''
		  puts client.send(mail)
		  
		  puts "sent to: " + g.email
		  
		  
	  end
	  render :text => "sent"
	end	
end
