class ReviewsController < ApplicationController

    def create
        order = Order.find(review_params[:order_id])

        if order && current_user.id == order.buyer.id
            if Review.exists?(order_id: review_params[:order_id], buyer_id: current_user.id)
                flash[:alert] = "You already made the review for this order"
            else
                review = Review.new(review_params)
                review.content = order.content
                review.buyer = current_user
                review.creator = order.creator

                if review.save
                    flash[:notice] = "Saved..."
                else
                    flash[:alert] = "Cannot create review"
                end
            end
        else
            flash[:alert] = "Invalid order"
        end
        redirect_to request.referrer
    end

    private

    def review_params
        params.require(:review).permit(:stars, :review, :order_id)
    end
end