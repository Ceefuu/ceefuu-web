class CommentsController < ApplicationController
    before_action :authenticate_user!
    before_action :is_valid_order

    def create
        order = Order.find(comment_params[:order_id])

        if comment_params[:content].blank? && comment_params[:attachment_file].blank?
            return redirect_to request.referrer, alert: "Invalid message"
        end

        if order.buyer_id != current_user.id && order.creator_id != current_user.id
            return render json: {success: false}
        end

        @comment = Comment.new(
            user_id: current_user.id,
            order_id: order.id,
            content: comment_params[:content],
            attachment_file: comment_params[:attachment_file]
        )

        if @comment.save
            order = @comment.order
            CommentChannel.broadcast_to order, message: render_comment(@comment)
            if current_user.id == order.buyer.id
              CommentMailer.with(comment: @comment, order: order).creator_comment_email.deliver_now
            elsif current_user.id == order.creator.id
              CommentMailer.with(comment: @comment, order: order).buyer_comment_email.deliver_now
            end
        else
            redirect_to request.referrer, alert: "Cannot create comment"
        end
    end

    private

    def render_comment(comment)
        self.render_to_string partial: 'orders/comment', locals: {comment: comment}
    end

    def comment_params
        params.require(:comment).permit(:content, :order_id, :attachment_file)
    end

    def is_valid_order
        redirect_to dashboard_path, alert: "Invalid order" unless Order.find(comment_params[:order_id]).present?
    end
end