class Api::HabitsController < Api::BaseController
  before_filter :authenticate_user!, only: [:show, :create, :update]
  
  def index
    habits = Habit.all
  
    return render(
      status: 200,
      json: ActiveModel::ArraySerializer.new(
        habits,
        each_serializer: Api::HabitSerializer,
        root: 'habits',
      )
    )
  end
  
  def show
    habit = Habit.find(params[:id])
    
    return render(
      status: 200,
      json: Api::HabitSerializer.new(habit).to_json
    )
  end
  
  def create
    habit = Habit.new(create_params)
    
    return render(
      status: 422,
      json: habit.errors
    ) unless habit.valid?

    habit.save!

    return render(
      status: 201,
      json: Api::HabitSerializer.new(habit).to_json,
      location: api_habit_path(habit.id)
    )
  end
  
   def update
     habit = Habit.find(params[:id])
     habit.update_attributes(update_params)
     
     render(
       status: 201,
       json: Api::HabitSerializer.new(habit).to_json,
       location: api_habit_path(habit.id)
     )
  end

  private
   def update_params
     create_params
  end
  
  def create_params
    params.require(:habit).permit(
      :name, :habit_system_id
    ).delete_if{ |k,v| v.nil?}
  end
  
end