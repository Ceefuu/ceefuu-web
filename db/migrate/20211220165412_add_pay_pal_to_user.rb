class AddPayPalToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :paypal, :string
  end
end
