class Admin::FeedCategoriesController < Admin::AdminController
  def index
    @feed_categories = FeedCategory.all
  end

  def show
    @feed_category = FeedCategory.find(params[:id])
  end

  def new
    @feed_category = FeedCategory.new
  end

  def create
    @feed_category = FeedCategory.new(params[:feed_category])
    if @feed_category.save
      flash[:notice] = "Successfully created feed category."
      redirect_to admin_feed_categories_path
    else
      render :new
    end
  end

  def edit
    @feed_category = FeedCategory.find(params[:id])
  end

  def update
    @feed_category = FeedCategory.find(params[:id])
    if @feed_category.update_attributes(params[:feed_category])
      flash[:notice] = "Successfully updated feed category."
      redirect_to admin_feed_categories_path
    else
      render :edit
    end
  end

  def destroy
    @feed_category = FeedCategory.find(params[:id])
    @feed_category.destroy
    flash[:notice] = "Successfully destroyed feed category."
    redirect_to admin_feed_categories_path
  end
end
