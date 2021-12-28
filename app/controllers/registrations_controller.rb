class RegistrationsController < Devise::RegistrationsController

  def new
    @username = params[:username]
    super
  end

  protected
  def update_resource(resource, params)
    resource.update_without_password(params)
  end
end