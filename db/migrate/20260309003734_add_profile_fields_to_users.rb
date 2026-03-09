class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string, null: false
    add_column :users, :bio, :text
    add_column :users, :github_uid, :string
    add_column :users, :github_username, :string
    add_column :users, :linkedin_uid, :string
    add_column :users, :linkedin_username, :string
    add_column :users, :portfolio_url, :string
    add_column :users, :site_admin, :boolean, default: false

    add_index :users, :github_uid, unique: true, where: "github_uid IS NOT NULL"
    add_index :users, :linkedin_uid, unique: true, where: "linkedin_uid IS NOT NULL"
  end
end
