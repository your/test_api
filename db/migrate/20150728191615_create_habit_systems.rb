class CreateHabitSystems < ActiveRecord::Migration
  def change
    create_table :habit_systems do |t|
      t.string :name
      t.references :user, index: true
      
      t.timestamps null: false
    end
  end
end
