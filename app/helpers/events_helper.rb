module EventsHelper
  
  def can_close_link? event     
    event.status == false || (event.end_time && event.end_time > Time.now) || (event.end_time==nil && event.start_time + 10800 > Time.now ) ? false : true
  end
  
  def can_edit? event
    event && event.status == false ? false : true
  end
end
