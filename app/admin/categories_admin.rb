Trestle.resource(:categories) do
  menu do
    item :categories, icon: "fa fa-star"
  end

  # Customize the table columns shown on the index view.
  
  table do
    column :name
    column :active
    column :created_at, align: :center
    actions do |toolbar, instance, admin|
      toolbar.link 'Activate', admin.path(:activate, id: instance.id), method: :post, class: 'btn btn-success'
      toolbar.link 'Deactivate', admin.path(:deactivate, id: instance.id), method: :post, class: 'btn btn-danger'
    end
  end

  controller do
    def activate
      cat = admin.find_instance(params)
      cat.update(active: true)

      flash[:message] = "Category is activated"
      redirect_to admin.path(:show, id: cat)
    end

    def deactivate
      cat = admin.find_instance(params)
      cat.update(active: false)

      flash[:message] = "Category is deactivated"
      redirect_to admin.path(:show, id: cat)
    end
  end

  routes do
    post :activate, on: :member
    post :deactivate, on: :member
  end

  form do |category|
    text_field :name
    text_field :id
  end
end
