class CreateHabitSystems < ActiveRecord::Migration
  def change
    create_table :habit_systems do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
