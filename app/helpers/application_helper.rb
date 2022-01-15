module ApplicationHelper
    def avatar_url(user)
        if user.avatar.attached?
            url_for(user.avatar)
        elsif user.image?
            user.image
        else
            ActionController::Base.helpers.asset_path('icon_default_avatar.png')
        end
    end

    def content_cover(content)
        if content.photos.attached?
            url_for(content.photos[0])
        else
            ActionController::Base.helpers.asset_path('icon_default_image.png')
        end
    end

    def title(page_title)
        content_for(:title) { page_title }
    end

    def stripe_express_path
        "https://connect.stripe.com/express/oauth/authorize?response_type=code&client_id=#{Rails.application.credentials.dig(:stripe, :connect_client_id)}&scope=read_write"
    end

end
