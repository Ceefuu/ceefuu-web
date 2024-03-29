class PagesController < ApplicationController
  def home
  end

  def search
    @categories = Category.all
    @category = Category.friendly.find(params[:category]) if params[:category].present?

    # @gigs = Gig.where("active = ? AND gigs.title ILIKE ? AND category_id = ?", true, "%#{params[:q]}%", params[:category])

    @q = params[:q]
    @min = params[:min]
    @max = params[:max]
    @delivery = params[:delivery].present? ? params[:delivery] : "0"
    @sort = params[:sort].present? ? params[:sort] : "price asc"

    query_condition = []
    query_condition[0] = "contents.active = true"
    query_condition[0] += " AND ((contents.has_single_price = true AND pricings.pricing_type = 0) OR (contents.has_single_price = false))"

    if !@q.blank?
      query_condition[0] += " AND contents.title ILIKE ?"
      query_condition.push "%#{@q}%"
    end

    if !params[:category].blank?
      query_condition[0] += " AND category_id = ?"
      query_condition.push params[:category]
    end

    if !params[:min].blank?
      query_condition[0] += " AND pricings.price >= ?"
      query_condition.push @min
    end

    if !params[:max].blank?
      query_condition[0] += " AND pricings.price <= ?"
      query_condition.push @max
    end

    if !params[:delivery].blank? && params[:delivery] != "0"
      query_condition[0] += " AND pricings.delivery_time <= ?"
      query_condition.push @delivery
    end

    @contents = Content.active_contents
                .select("contents.id, contents.title, contents.user_id, MIN(pricings.price) AS price, pitch, slug")
                .joins(:pricings)
                .where(query_condition)
                .group("contents.id")
                .order(@sort)
                .page(params[:page])
                .per(6)
  end

  def calendar
    params[:start_date] ||= Date.current.to_s

    start_date = Date.parse(params[:start_date])
    first_of_month = (start_date - 1.month).beginning_of_month
    end_of_month = (start_date + 1.month).end_of_month

    @orders = Order.where("creator_id = ? AND status = ? AND due_date BETWEEN ? AND ?", 
                          current_user.id,
                          Order.statuses[:inprogress],
                          first_of_month,
                          end_of_month)
  end

  def plans
    @plans = Stripe::Plan.list(product: 'prod_KoZhTFi2yCK8WU')
  end

  def terms
  end

  def privacy
  end

  def cookies
  end
end
