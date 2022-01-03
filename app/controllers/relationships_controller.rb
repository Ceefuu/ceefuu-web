class RelationshipsController < ApplicationController

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    redirect_to request.referrer, notice: "Followed Successfully"
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    redirect_to request.referrer, notice: "Unfollowed Successfully"
  end
end
