class Api::HabitSerializer < Api::BaseSerializer
  attributes :id, :name

  #has_many :habit_systems
end