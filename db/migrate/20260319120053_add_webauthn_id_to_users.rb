class AddWebauthnIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :webauthn_id, :string, null: false, default: -> { "gen_random_uuid()" }
    add_index :users, :webauthn_id, unique: true
  end
end
