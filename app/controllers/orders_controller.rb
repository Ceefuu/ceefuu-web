class OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :is_authorised, only: [:show]
    
    def create
        content = Content.friendly.find(params[:content_id])
        pricing = content.pricings.find_by(pricing_type: params[:pricing_type])

        if (pricing && !content.has_single_price) || (pricing && pricing.basic? && content.has_single_price)
            if intent(content, pricing)
                OrderMailer.with(buyer_user: current_user).order_buyer_email.deliver_now
                OrderMailer.with(creator_user: content.user).order_creator_email.deliver_now
                return redirect_to buying_orders_path
            end
        else
            flash[:alert] = "Price is incorrect"
        end

        return redirect_to request.referrer
    end

    def selling_orders
        @orders = current_user.selling_orders.order("created_at DESC")
    end

    def buying_orders
        @orders = current_user.buying_orders.order("created_at DESC")
    end

    def complete
        @order = Order.find(params[:id])

        if !@order.completed?
            if @order.completed!
                OrderMailer.with(order: @order).mark_as_complete_buyer_email.deliver_now
                OrderMailer.with(order: @order).mark_as_complete_creator_email.deliver_now
                flash[:notice] = "Saved..."
            else
                flash[:aler] = "Something went wrong..."
            end

            redirect_to request.referrer
        end
    end

    def show
        @order = Order.find(params[:id])
        @content = @order.content_id ? Content.find(@order.content_id) : nil
        # @request = @order.request_id ? Request.find(@order.request_id) : nil
        @comments = Comment.where(order_id: params[:id])
    end

    private

    def is_authorised
        redirect_to dashboard_path, 
            alert: "You don't have permission" unless Order.where("id = ? AND (creator_id = ? OR buyer_id = ?", 
                                                                    params[:id], current_user.id, current_user.id)
    end

    def intent(content, pricing)

        subscription = Subscription.find_by_user_id(current_user.id)
        if subscription.present? && subscription.success?
            plan = Stripe::Plan.retrieve(subscription.plan_id)
            rate =  plan.metadata.commission.to_f/100
        else
            rate = 20.0/100
        end

        amount = pricing.price * (rate + 1)

        order = content.orders.new
        order.due_date = Date.today() + pricing.delivery_time.days
        order.title = content.title
        order.creator_name = content.user.full_name
        order.creator_id = content.user.id
        order.buyer_name = current_user.full_name
        order.buyer_id = current_user.id
        order.amount = amount

        if params[:payment].blank?
            flash[:alert] = "No payment selected"
            return false
        # elsif params[:payment] == "system"
        #     if amount > current_user.wallet
        #         flash[:alert] = "Not enought money"
        #         return false
        #     else
        #         ActiveRecord::Base.transaction do
        #             current_user.update!(wallet: current_user.wallet - amount)
        #             content.user.update!(wallet: content.user.wallet + pricing.price)
        #             Transaction.create! status: Transaction.statuses[:approved],
        #                                 transaction_type: Transaction.transaction_types[:trans],
        #                                 source_type: Transaction.source_types[:system],
        #                                 buyer: current_user,
        #                                 creator: content.user,
        #                                 amount: amount,
        #                                 content: content
        #             order.save
        #         end
        #         flash[:notice] = "Your order is created successfully"
        #         return true
        #     end
        else
            # TODO: 
            # 1. find better way to handle Stripe Payment Intent API
            # 2. Move Stripe Payment Intent API logic to service


            payment_intent = Stripe::PaymentIntent.create({
                amount: (amount * 100).to_i,
                currency: 'usd',
                confirm: true,
                customer: current_user.stripe_id,
                :transfer_data => {
                    :amount => (pricing.price * 100).to_i,
                    :destination => content.user.merchant_id # Host's Stripe customer ID
                  }
            })

            if payment_intent.status == 'succeeded'
                ActiveRecord::Base.transaction do
                    # content.user.update!(wallet: content.user.wallet + pricing.price)
                    Transaction.create! status: Transaction.statuses[:approved],
                                        transaction_type: Transaction.transaction_types[:trans],
                                        source_type: Transaction.source_types[:stripe],
                                        buyer: current_user,
                                        creator: content.user,
                                        amount: amount,
                                        content: content
                    order.save
                end
                flash[:notice] = "Your order is created successfully"
                return true
            end
            flash[:alert] = "Invalid card"
            return false
        end

    rescue ActiveRecord::RecordInvalid
        flash[:alert] = "Something went wrong"
        return false
    end
end