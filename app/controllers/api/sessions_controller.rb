class Api::SessionsController < Api::BaseController
  def create
    user = User.find_by(email: create_params[:email])
    if user && user.authenticate(create_params[:password])
      self.current_user = user
      return render(
        status: 201,
        json: Api::SessionSerializer.new(user, root: false).to_json
      )
    else
      return render(
        status: 401,
        json: { error: 'Authentication error' }
      )
    end
  end

  private
  def create_params
    params.require(:user).permit(:email, :password)
  end
end