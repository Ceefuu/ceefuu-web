Trestle.admin(:dashboard) do
    menu do
        item :dashboard, icon: "fa fa-tachometer"
    end

    controller do 
        def index
            @user_count = User.count()
            @content_count = Content.count()
            @order_count = Order.count()
            @categories_count = Category.count()
        end
    end
end