class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.string :title, null: false
      t.integer :discipline, null: false
      t.string :commitment
      t.string :location, default: "Remote"
      t.string :skills
      t.integer :status, default: 0, null: false
      t.datetime :discarded_at
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end

    add_index :listings, :discarded_at
    add_index :listings, [ :organization_id, :status ]
  end
end
