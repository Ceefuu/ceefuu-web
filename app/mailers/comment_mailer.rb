class CommentMailer < ApplicationMailer

  def buyer_comment_email
    @comment = params[:comment]
    @order = params[:order]
    mail(to: @comment.order.buyer.email, subject: 'Creator post a comment')
  end

  def creator_comment_email
    @comment = params[:comment]
    @order = params[:order]
    mail(to: @comment.order.creator.email, subject: 'Buyer post a comment')
  end
end
