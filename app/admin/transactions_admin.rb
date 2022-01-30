Trestle.resource(:Transactions) do
  remove_action :destroy

  menu do
    item :orders, icon: "fa fa-money", label: "Transactions"
  end

  table do
    column :buyer 
    column :creator 
    column :content
    column :amount
    column :status
    column :created_at, align: :center
  end
  
end
