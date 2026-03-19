class CreateTodoItems < ActiveRecord::Migration[8.1]
  def change
    create_table :todo_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.boolean :completed, default: false, null: false
      t.datetime :completed_at
      t.date :due_date, null: false
      t.date :original_due_date, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :todo_items, [ :user_id, :due_date, :completed ]
    add_index :todo_items, [ :user_id, :completed, :due_date ]
  end
end
