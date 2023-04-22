# frozen_string_literal: true

class ProductsController < StoreController
  before_action :load_product, only: :show
  before_action :load_taxon, only: :index
  before_action :load_day_schedule_product, only: :day_schedule

  helper 'spree/products', 'spree/taxons', 'taxon_filters'

  respond_to :html

  rescue_from Spree::Config.searcher_class::InvalidOptions do |error|
    raise ActionController::BadRequest.new, error.message
  end

  def index
    @searcher = build_searcher(params.merge(include_images: true))
    @products = @searcher.retrieve_products
  end

  def show
    @variants = @product.
      variants_including_master.
      display_includes.
      with_prices(current_pricing_options).
      includes([:option_values, :images])

    @product_properties = @product.product_properties.includes(:property)
    @taxon = Spree::Taxon.find(params[:taxon_id]) if params[:taxon_id]
  end

  def day_schedule
    @instances = Array.new(24, @product)
  
    if request.post?
      add_selected_products_to_cart
      redirect_to spree.cart_path
    end
  end
  
  private
  
  def add_selected_products_to_cart
    selected_products = params[:selected_products].select { |_, v| v.present? }
    selected_products.each do |_index, variant_id|
      current_order.contents.add(Spree::Variant.find(variant_id), 1)
    end
  end

  def accurate_title
    if @product
      @product.meta_title.blank? ? @product.name : @product.meta_title
    else
      super
    end
  end

  def load_product
    if spree_current_user.try(:has_spree_role?, "admin")
      @products = Spree::Product.with_discarded
    else
      @products = Spree::Product.available
    end
    @product = @products.friendly.find(params[:id])
  end

  def load_taxon
    @taxon = Spree::Taxon.find(params[:taxon]) if params[:taxon].present?
  end

  def load_day_schedule_product
    @product = Spree::Product.find_by(slug: params[:id])
    unless @product
      flash[:error] = "Le produit demandé n'a pas été trouvé."
      redirect_to root_path
    end
  end
end
