class AddEmailConfirmedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_confirmed_at, :datetime

    reversible do |dir|
      dir.up { execute "UPDATE users SET email_confirmed_at = NOW() WHERE email_confirmed_at IS NULL" }
    end
  end
end
