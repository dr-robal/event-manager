class PagesController < ApplicationController
  before_filter :check_facebook_cookies, :only => [:login] 
  

  
  def check_facebook_cookies    
    session['oauth'] ||= Koala::Facebook::OAuth.new(Facebook::CALLBACK_URL + 'callback')
  end
  
  def home
    @face = session['access_token'] if session['access_token']
  end
  
  def callback    
    session['access_token'] = session['oauth'].get_access_token(params[:code])
    redirect_to root_url
  end
  
  def login
    url = session['oauth'].url_for_oauth_code(:permissions => "create_event")#(:permissions => "publish_stream")
    redirect_to url
  end
  
  def logout
    session['oauth'] = nil
    session['access_token']=nil
    redirect_to root_url
  end
    
end
