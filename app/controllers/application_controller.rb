class ApplicationController < ActionController::Base
  protect_from_forgery
  

  def check_access_token
    redirect_to root_url, notice: 'You have to be logged in.' if session['access_token']==nil
  end
  #def parse_facebook_cookies
  # @facebook_cookies = Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies)
  #end
end
