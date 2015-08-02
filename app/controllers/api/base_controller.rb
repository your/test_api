class Api::BaseController < ApplicationController

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :destroy_session

  rescue_from ActiveRecord::RecordNotFound, with: :not_found!

  attr_accessor :current_user
  protected


  def authenticate_user!
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)
    #p token
    #p options

    #user_email = options.blank?? nil : options[:email]
    #user = user_email && User.find_by(email: user_email)
    
    user = User.find_by(token: token)

    if user && ActiveSupport::SecurityUtils.secure_compare(user.token, token)
      @current_user = user
    else
      return unauthenticated!
    end
  end
  
  def unauthenticated!
    response.headers['WWW-Authenticate'] = "Token realm=Application"
    render json: { error: 'Bad credentials' }, status: 401
  end
  
  def not_found!
    return render(
      status: 404,
      json: { error: 'Not found' }
    )
  end

  def destroy_session
    request.session_options[:skip] = true
  end
  

end