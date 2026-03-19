class CreateEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :entries do |t|
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.text :body_html
      t.integer :tag, null: false, default: 0
      t.date :posted_on, null: false

      t.timestamps
    end

    add_index :entries, [ :user_id, :posted_on ]
    add_index :entries, [ :user_id, :tag, :posted_on ]
  end
end
