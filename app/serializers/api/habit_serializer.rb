class Api::HabitSerializer < Api::BaseSerializer
  attributes :id, :name

  has_one :user
end