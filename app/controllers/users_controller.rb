class UsersController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    @subscription = Subscription.find_by_user_id(current_user.id)
    if @subscription.present?
      @plan = Stripe::Plan.retrieve(@subscription.plan_id)
    end
  end

  def show
    @user = User.find(params[:id])
    @reviews = Review.where(creator_id: params[:id]).order("created_at desc")
  end

  def update
    @user = current_user
    if @user.update(current_user_params)
      flash[:notice] = "Saved..."
    else
      flash[:alert] = "Cannot update..."
    end
    redirect_to dashboard_path
  end

  # def update_phone
  #   current_user.update_attributes(user_params)
  #   current_user.generate_pin
  #   current_user.send_pin

  #   redirect_to edit_user_registration_path, notice: "Saved..."
  # rescue Exception => e
  #   redirect_to edit_user_registration_path, alert: "#{e.message}"
  # end

  # def verify_phone
  #   current_user.verify_pin(params[:user][:pin])

  #   if current_user.phone_verified
  #     flash[:notice] = "Your phone number is verified."
  #   else
  #     flash[:alert] = "Cannot verify your phone number."
  #   end

  #   redirect_to edit_user_registration_path

  # rescue Exception => e
  #   redirect_to edit_user_registration_path, alert: "#{e.message}"
  # end

  def update_payment
    if !current_user.stripe_id
      customer = Stripe::Customer.create(
        email: current_user.email,
        name: current_user.full_name,
        source: params[:stripeToken]
      )
    else
      customer = Stripe::Customer.update(
        current_user.stripe_id,
        source: params[:stripeToken]
      )
    end

    if current_user.update(stripe_id: customer.id)
      flash[:notice] = "New card is saved"
    else
      flash[:alert] = "Invalid card"
    end
    redirect_to request.referrer
  rescue Stripe::CardError => e
    flash[:alert] = e.message
    redirect_to request.referrer
  end

  def update_payout
    if !current_user.merchant_id.blank?
      account = Stripe::Account.retrieve(current_user.merchant_id)
      @login_link = account.login_links.create()
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to request.referrer
  end

  def earnings
    @net_income = (Transaction.where("creator_id = ?", current_user.id).sum(:amount) / 1.1).round(2)

    # @withdrawn = Transaction.where("buyer_id = ? AND status = ? AND transaction_type = ?",
    #                 current_user.id,
    #                 Transaction.statuses[:approved],
    #                 Transaction.transaction_types[:withdraw]
    #             ).sum(:amount)
    
    # @pending = Transaction.where("buyer_id = ? AND status = ? AND transaction_type = ?",
    #             current_user.id,
    #             Transaction.statuses[:pending],
    #             Transaction.transaction_types[:withdraw]
    #             ).sum(:amount)

    # @purchased = Transaction.where("buyer_id = ? AND source_type = ? AND transaction_type = ?",
    #             current_user.id,
    #             Transaction.source_types[:system],
    #             Transaction.transaction_types[:trans]
    #             ).sum(:amount)

    # @withdrawable = current_user.wallet

    @transactions = Transaction.where("creator_id = ? OR (buyer_id = ? AND source_type = ?)",
                    current_user.id,
                    current_user.id,
                    Transaction.source_types[:system]
                  ).page(params[:page]).order("created_at DESC")
  end

  # def withdraw
  #   amount = params[:amount].to_i
  #   is_pending_withdraw = Transaction.exists?(buyer_id: current_user.id, 
  #                                             status: Transaction.statuses[:pending],
  #                                             transaction_type: Transaction.transaction_types[:withdraw])
    
  #   if amount <= 0
  #     flash[:alert] = "Invalid amount"
  #   elsif amount > current_user.wallet
  #     flash[:alert] = "You're asking for more than you have"
  #   elsif !is_pending_withdraw.blank?
  #     flash[:alert] = "You currently have a pending withdraw request"
  #   else
  #     transaction = Transaction.new
  #     transaction.status = Transaction.statuses[:pending]
  #     transaction.transaction_type = Transaction.transaction_types[:withdraw]
  #     transaction.source_type = Transaction.source_types[:system]
  #     transaction.buyer = current_user
  #     transaction.amount = amount

  #     if transaction.save
  #       flash[:notice] = "Create withdraw request successfully"
  #     else
  #       flash[:alert] = "Cannot create a request"
  #     end
  #   end

  #   redirect_to request.referrer
  # end

  def remove_subscription
    @subscription = Subscription.find_by_user_id(current_user.id)

    if @subscription.present? && @subscription.sub_id
      Stripe::Subscription.delete(@subscription.sub_id)
      return redirect_to request.referrer, notice: "Your subscription is cancelled"
    end
    return redirect_to request.referrer, aler: "Cannot cancel your subscription. Contact admin."
  end

  def payment
    if current_user.stripe_id.present?
      payment_cards = Stripe::Customer.list_sources(
                        current_user.stripe_id,
                        {object: 'card'},
                      )
      @card_detail = payment_cards.data.first
    end
  end

  private
  def current_user_params
    params.require(:user).permit(:from, :about, :status, :language, :avatar)
  end
end
