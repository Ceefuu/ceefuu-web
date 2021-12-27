class RemoveLast4FromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :stripe_last_4, :string
  end
end
