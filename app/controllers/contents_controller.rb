class ContentsController < ApplicationController

  protect_from_forgery except: [:upload_photo]
  before_action :authenticate_user!, except: [:show]
  before_action :set_content, except: [:new, :create]
  before_action :is_authorised, only: [:edit, :update, :upload_photo, :delete_photo]
  before_action :set_step, only: [:update, :edit]

  def new
    @content = current_user.contents.build
    @categories = Category.all
  end

  def create
    @content = current_user.contents.build(content_params)

    if @content.save
      @content.pricings.create(Pricing.pricing_types.values.map{ |x| {pricing_type: x} })
      redirect_to edit_content_path(@content), notice: "Save..."
    else
      redirect_to request.referrer, flash: { error: @content.errors.full_messages }
    end
  end

  def edit
    @categories = Category.all
  end

  def update

    if @step == 2
      content_params[:pricings_attributes].each do |index, pricing|
        if @content.has_single_price && pricing[:pricing_type] != Pricing.pricing_types.key(0)
          next;
        else
          if pricing[:title].blank? || pricing[:description].blank? || pricing[:delivery_time].blank? || pricing[:price].blank?
            return redirect_to request.referrer, flash: {error: "Invalid pricing"}
          end
        end
      end
    end

    if @step == 3 && content_params[:description].blank?
      return redirect_to request.referrer, flash: {error: "Description cannot be blank"}
    end

    if @step == 4 && @content.photos.blank?
      return redirect_to request.referrer, flash: {error: "You don't have any photos"}
    end

    if @step == 5
      @content.pricings.each do |pricing|
        if @content.has_single_price && !pricing.basic?
          next;
        else
          if pricing[:title].blank? || pricing[:description].blank? || pricing[:delivery_time].blank? || pricing[:price].blank?
            return redirect_to edit_content_path(@content, step: 2), flash: {error: "Invalid pricing"}
          end
        end
      end

      if @content.description.blank?
        return redirect_to edit_content_path(@content, step: 3), flash: {error: "Description cannot be blank"}
      elsif @content.photos.blank?
        return redirect_to edit_content_path(@content, step: 4), flash: {error: "You don't have any photos"}
      end
    end

    if @content.update(content_params)
      flash[:notice] = "Saved..."
    else
      return redirect_to request.referrer, flash: {error: @content.errors.full_messages}
    end

    if @step < 5
      redirect_to edit_content_path(@content, step: @step + 1)
    else
      redirect_to dashboard_path
    end

  end

  def show
    @categories = Category.all
  end

  def upload_photo
    @content.photos.attach(params[:file])
    render json: { success: true }
  end

  def delete_photo
    @image = ActiveStorage::Attachment.find(params[:photo_id])
    @image.purge
    redirect_to edit_content_path(@content, step: 4)
  end

  def checkout
    subscription = Subscription.find_by_user_id(current_user.id)
    if subscription.present? && subscription.success?
      plan = Stripe::Plan.retrieve(subscription.plan_id)
      @rate =  plan.metadata.commission.to_f/100
    else
      @rate = 10.0/100
    end

    if current_user.stripe_id
      # @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_id)
      @stripe_customer = Stripe::Customer.list_sources(
                            current_user.stripe_id,
                            {object: 'card'},
                          )
      @content = Content.find(params[:id])
      @pricing = @content.pricings.find_by(pricing_type: params[:pricing_type])
    else
      redirect_to settings_payment_path, alert: "Please add your card first"
    end
  end

  private

  def set_step
    @step = params[:step].to_i > 0 ? params[:step].to_i : 1
    if @step > 5
      @step = 5
    end
  end

  def set_content
    @content = Content.friendly.find(params[:id])
  end

  def is_authorised
    redirect_to root_path, alert: "You do not have permission" unless current_user.id == @content.user_id
  end

  def content_params
    params.require(:content).permit(:title, :pitch, :description, :active, :category_id, :has_single_price, 
                                pricings_attributes: [:id, :title, :description, :delivery_time, :price, :pricing_type])
  end

  def should_generate_new_friendly_id?
    title_changed?
    end
end
