class CreateFlags < ActiveRecord::Migration[8.1]
  def change
    create_table :flags do |t|
      t.references :user, null: false, foreign_key: true
      t.references :flaggable, polymorphic: true, null: false
      t.text :reason, null: false
      t.integer :status, default: 0, null: false
      t.timestamps
    end
    add_index :flags, [ :user_id, :flaggable_type, :flaggable_id ], unique: true
  end
end
