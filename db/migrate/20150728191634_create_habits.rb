class CreateHabits < ActiveRecord::Migration
  def change
    create_table :habits do |t|
      t.string :name
      t.references :user, index: true
      
      t.timestamps null: false
    end
    add_index :habits, [:user_id, :created_at]
  end
end
