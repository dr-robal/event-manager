class EventsController < ApplicationController
  before_filter :check_access_token, :except => [:index, :oldevents]
  before_filter :privacy, :except => [:index, :show, :oldevents, :destroy]
  before_filter :graph_api, :except => [:index, :oldevents]
   
  # GET /events
  # GET /events.json
  def index
    @events = Event.all(:conditions => ['status like ? ', true])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end
  
  def oldevents
    @events = Event.all(:conditions => ['status like ? ', false])
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  def attending
    @event = Event.find(params[:id])
    
    get_attending @event.facebookID
  end
  
  def maybeattending
    @event = Event.find(params[:id])
    
    get_attending @event.facebookID
  end
  
  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    
    params['facebook'] = {
      :name => params[:event][:name],
      :start_time => get_date_string_from_params(params[:event]['start_time(1i)'],params[:event]['start_time(2i)'],params[:event]['start_time(3i)'],params[:event]['start_time(4i)'],params[:event]['start_time(5i)']),
      :end_time => get_date_string_from_params(params[:event]['end_time(1i)'],params[:event]['end_time(2i)'],params[:event]['end_time(3i)'],params[:event]['end_time(4i)'],params[:event]['end_time(5i)']),
      :description => params[:event][:description],
      :location => params[:event][:location],
      :privacy_type => params[:event][:privacy_type]
      
      
    }
    
      @event = Event.new(params[:event])
      @event.status = true
      
      respond_to do |format|
        if @event.valid?
          faceresponse = @graph.put_object('me', 'events', params['facebook'] )
          if faceresponse
            @event.facebookID = faceresponse['id']
            @event.save
          
            format.html { redirect_to @event, notice: 'Event was successfully created.' }
            format.json { render json: @event, status: :created, location: @event }   
          else
            format.html { render action: "new", notice: 'Error on facebook occure.' }
          end
        else
          format.html { render action: "new" }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    
    params['facebook'] = {
      :name => params[:event][:name],
      :start_time => get_date_string_from_params(params[:event]['start_time(1i)'],params[:event]['start_time(2i)'],params[:event]['start_time(3i)'],params[:event]['start_time(4i)'],params[:event]['start_time(5i)']),
      :end_time => get_date_string_from_params(params[:event]['end_time(1i)'],params[:event]['end_time(2i)'],params[:event]['end_time(3i)'],params[:event]['end_time(4i)'],params[:event]['end_time(5i)']),
      :description => params[:event][:description],
      :location => params[:event][:location],
      :privacy_type => params[:event][:privacy_type]
      
      
    }
    	
    @event = Event.find(params[:id])
	@event.assign_attributes(params[:event])
	
    respond_to do |format|
      if @event.valid?
         faceresponse = @graph.put_object(@event.facebookID,'', params['facebook'] )
         if faceresponse == true
           @event.update_attributes(params[:event])
          
           format.html { redirect_to @event, notice: 'Event was successfully updated.' }
           format.json { head :no_content }
         else
           format.html { render action: "edit", notice: 'Error on facebook occure.' }
         end
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    faceresponse = @graph.delete_object(@event.facebookID)
    
    if faceresponse == true
      @event.destroy

      respond_to do |format|
        format.html { redirect_to events_url }
        format.json { head :no_content }
      end
    end
  end
  
  def close
    @event = Event.find(params[:id])
    
    can_close? @event
    
    get_attending @event.facebookID
  end
  
  def close_update
    #event = Event.new(params[:event])
	
	@event = Event.find(params[:id])
    @event.assign_attributes(params[:event])
	
    get_attending @event.facebookID
    
    @event.status = false
    
    respond_to do |format|
      if @event.valid?
        
           @event.update_attributes(params[:event])
        
        format.html { redirect_to events_url, :notice => "Closed successfully" }
      else
		#@event.update_attributes(params[:event])
        format.html { render action: "close" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def get_actual_statistics
    @events = Event.all(:conditions => ['status like ? ', true])
    
    @events.each do |event|
      get_attending event.facebookID
      event.update_attributes(:participants_declared => @attending.size, :participants_maybe => @maybe_attending.size)
      event.save
    end
      
    redirect_to events_path
  end
    
  protected
    def privacy
      @privacy_type = Event.privacy_type_list
    end
    
    def get_attending faceEventID
      @attending = @graph.get_connections(faceEventID, 'attending')
      @maybe_attending = @graph.get_connections(faceEventID, 'maybe')
    end
    
    def can_close? event
      redirect_to event_path, notice: 'Cannot close closed event.' if event.status == false
      redirect_to event_path, notice: 'Cannot close event that is not finished.' if (event.end_time && event.end_time > Time.now) || (event.end_time==nil && event.start_time + 10800 > Time.now )
    end
     
    def graph_api
      @graph ||= Koala::Facebook::API.new(session['access_token'])
    end

    def get_date_string_from_params(year,month,day,hour,minute)
      year + '-' + month + '-' + day + ' ' + hour + ':' + minute if (year.to_s+month.to_s+day.to_s+hour.to_s+minute.to_s).size!=0
    end
end
