class Api::HabitSystemSerializer < Api::BaseSerializer
  attributes :id, :name

  has_many :habits
  #has_one :user
end