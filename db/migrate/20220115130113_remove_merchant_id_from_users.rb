class RemoveMerchantIdFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :merchant_id
  end
end
