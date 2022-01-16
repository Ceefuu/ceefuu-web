class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def facebook
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.from_omniauth(request.env["omniauth.auth"])
  
      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
      else
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end

    def stripe_connect
      response = Stripe::OAuth.token({
        grant_type: 'authorization_code',
        code: params[:code],
      })
      @user = current_user
  
      if @user.persisted?
        @user.merchant_id = response.stripe_user_id
        @user.save
  
        if !@user.merchant_id.blank?
  
          # Update Payout Schedule
          account = Stripe::Account.retrieve(current_user.merchant_id)
          account.settings.payouts.schedule.delay_days = 7
          account.settings.payouts.schedule.interval = "daily"
  
          account.save
  
          logger.debug "#{account}"
        end
        
        sign_in_and_redirect @user, event: :authentication
        flash[:notice] = "Stripe Account Created and Connected" if is_navigational_format?
  
      else
        session["devise.stripe_connect_data"] = request.env["omniauth.auth"]
        redirect_to dashboard_path
      end
    end
  
    def failure
      redirect_to root_path
    end
end