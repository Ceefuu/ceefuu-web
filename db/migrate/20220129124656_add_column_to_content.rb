class AddColumnToContent < ActiveRecord::Migration[6.1]
  def change
    add_column :contents, :is_active, :boolean, default: false
  end
end
