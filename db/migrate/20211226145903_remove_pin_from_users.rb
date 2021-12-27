class RemovePinFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :pin, :string
    remove_column :users, :phone_verified, :boolean
  end
end
