class OrderMailer < ApplicationMailer

  def order_buyer_email
    buyer_user = params[:buyer_user]
    mail(to: buyer_user.email, subject: 'Order Placed')
  end

  def order_creator_email
    creator_user = params[:creator_user]
    mail(to: creator_user.email, subject: 'Order Created')
  end

  def mark_as_complete_buyer_email
    @order = params[:order]
    mail(to: @order.buyer.email, subject: 'You completed order')
  end

  def mark_as_complete_creator_email
    @order = params[:order]
    mail(to: @order.creator.email, subject: 'Your order completed by buyer')
  end
end
