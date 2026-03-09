class AddMessageToInterests < ActiveRecord::Migration[8.1]
  def change
    add_column :interests, :message, :text
  end
end
