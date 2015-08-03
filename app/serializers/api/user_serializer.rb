class Api::UserSerializer < Api::BaseSerializer
  attributes :id, :email, :name

  has_many :habit_systems
end