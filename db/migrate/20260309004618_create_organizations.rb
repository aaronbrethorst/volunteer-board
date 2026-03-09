class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :website_url
      t.string :repo_url
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :organizations, :slug, unique: true
    add_index :organizations, :discarded_at
  end
end
