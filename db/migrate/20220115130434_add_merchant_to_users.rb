class AddMerchantToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :merchant_id, :string
    add_column :users, :merchant_provider, :string
    add_column :users, :merchant_access_code, :string
    add_column :users, :merchant_publishable_key, :string
  end
end
