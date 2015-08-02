class Api::UserSerializer < Api::BaseSerializer
  attributes :id, :email, :name

  #has_many :habitsystems
  has_many :habits
end