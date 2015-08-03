class Api::HabitSystemsController < Api::BaseController
  before_filter :authenticate_user!, only: [:show, :create, :update]
  
  def index
    habit_systems = HabitSystem.all
  
    return render(
      status: 200,
      json: ActiveModel::ArraySerializer.new(
        habit_systems,
        each_serializer: Api::HabitSystemSerializer,
        root: 'habit_systems',
      )
    )
  end
  
  def show
    habit_system = HabitSystem.find(params[:id])
    
    return render(
      status: 200,
      json: Api::HabitSystemSerializer.new(habit_system).to_json
    )
  end
  
  def create
    habit_system = HabitSystem.new(create_params)
    
    return render(
      status: 422,
      json: habit_system.errors
    ) unless habit_system.valid?

    habit_system.save!

    return render(
      status: 201,
      json: Api::HabitSystemSerializer.new(habit_system).to_json,
      location: api_habit_system_path(habit_system.id)
    )
  end
  
   def update
     habit_system = HabitSystem.find(params[:id])
     habit_system.update_attributes(update_params)
     
     render(
       status: 201,
       json: Api::HabitSystemSerializer.new(habit_system).to_json,
       location: api_habit_system_path(habit_system.id)
     )
  end

  private
   def update_params
     create_params
  end
  
  def create_params
    params.require(:habit_system).permit(
      :name, :user_id
    ).delete_if{ |k,v| v.nil?}
  end
  
end