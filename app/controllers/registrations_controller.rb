class RegistrationsController < Devise::RegistrationsController

  def new
    if params[:username].present?
      user = User.find_by(username: params[:username])
      if user.present?
        redirect_to request.referrer, flash: { error: 'Username already taken' }
      else
        @username = params[:username]
        super
      end
    else
      super
    end
  end

  protected
  def update_resource(resource, params)
    resource.update_without_password(params)
  end
end