class HabitSystem < ActiveRecord::Base
  has_many :habits
  belongs_to :user
end
