class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.integer :status
      t.integer :transaction_type
      t.float :amount
      t.integer :source_type
      t.references :content, foreign_key: true
      t.references :buyer, foreign_key: { to_table: :users}
      t.references :creator, foreign_key: { to_table: :users}

      t.timestamps
    end
  end
end
