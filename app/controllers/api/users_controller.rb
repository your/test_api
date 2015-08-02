class Api::UsersController < Api::BaseController
  before_filter :authenticate_user!, only: [:show, :update]
  
  def index
    users = User.all
  
    return render(
      status: 200,
      json: ActiveModel::ArraySerializer.new(
        users,
        each_serializer: Api::UserSerializer,
        root: 'users',
      )
    )
  end
  
  def show
    user = User.find(params[:id])
    
    return render(
      status: 200,
      json: Api::UserSerializer.new(user).to_json
    )
  end
  
  def create
    user = User.new(create_params)
    
    return render(
      status: 422,
      json: user.errors
    ) unless user.valid?

    user.save!
    user.activate

    return render(
      status: 201,
      json: Api::UserSerializer.new(user).to_json,
      location: api_user_path(user.id)
    )
  end
  
   def update
     user = User.find(params[:id])
     user.update_attributes(update_params)
     
     render(
       status: 201,
       json: Api::UserSerializer.new(user).to_json,
       location: api_user_path(user.id)
     )
  end

  private
   def update_params
     create_params
  end
  
  def create_params
    params.require(:user).permit(
      :email, :password, :name
    ).delete_if{ |k,v| v.nil?}
  end
  
end