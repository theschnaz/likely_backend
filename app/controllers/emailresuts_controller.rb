class EmailresutsController < ApplicationController

  #duels that have been voted on yesterday
  duels = Snap.find_by_sql("select snaps.id, snaps.snapped_by, snaps.photo_url from snaps, votes where snaps.id = votes.snap_id and votes.updated_at >= '2015-02-28'")
  
  duels.each do |p|
  
    user = User.find_by_sql("select * from users, snaps where snaps.snapped_by = users.id and snaps.id = 70")
  
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

end
