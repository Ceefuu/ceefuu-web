Trestle.resource(:contents) do
  remove_action :new
  remove_action :destroy

  menu do
    item :contents, icon: "fa fa-creative-commons"
  end

  table do
    column :title
    column :active
    column :user, -> (obj) { obj.user.full_name }
    column :created_at, align: :center
    actions do |toolbar, instance, admin|
      toolbar.link 'Activate', admin.path(:activate, id: instance.id), method: :post, class: 'btn btn-success'
      toolbar.link 'Deactivate', admin.path(:deactivate, id: instance.id), method: :post, class: 'btn btn-danger'
    end
  end

  controller do
    def activate
      content = admin.find_instance(params)
      content.update(active: true)

      flash[:message] = "Content is activated"
      redirect_to admin.path(:show, id: content)
    end

    def deactivate
      content = admin.find_instance(params)
      content.update(active: false)

      flash[:message] = "Content is deactivated"
      redirect_to admin.path(:show, id: content)
    end
  end

  routes do
    post :activate, on: :member
    post :deactivate, on: :member
  end

  form do |content|
    text_field :title
    text_field :pitch
    editor :description
    select :category_id, Category.where(active: true)
  end

  search do |query|
    if query
      Content.where("title ILIKE ?", "%#{query}%")
    else
      Content.all
    end
  end
end
