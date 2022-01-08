class SessionsController < Devise::SessionsController

  def create
    user = User.find_by(email: params[:user][:email])
    if user.present? && !user.confirmed?
      redirect_to new_user_confirmation_path, flash: { error: 'You have to confirm your email address before continuing.' }
    else
      super
    end
  end
end