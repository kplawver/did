class FixUserEmailAndPasswordDefaults < ActiveRecord::Migration[8.1]
  def up
    change_column_default :users, :email, nil
    change_column_default :users, :encrypted_password, nil
  end

  def down
    change_column_default :users, :email, ""
    change_column_default :users, :encrypted_password, ""
  end
end
