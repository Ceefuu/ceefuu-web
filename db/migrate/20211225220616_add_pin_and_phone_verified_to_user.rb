class AddPinAndPhoneVerifiedToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :pin, :string
    add_column :users, :phone_verified, :boolean
  end
end
