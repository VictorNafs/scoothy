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
    @product = Spree::Product.find(params[:product_id])
    @selected_date = params[:selected_date] || Date.today
    @instances = @product.stock_items.joins(:stock_movements).where('spree_stock_movements.date = ?', @selected_date)
  
    # Récupérez les stock_movements pour la date sélectionnée et groupés par leur stock_item_id
    @stock_movements = Spree::StockMovement.where(date: @selected_date).group_by(&:stock_item_id)
  
    if request.post?
      add_selected_products_to_cart
      redirect_to spree.cart_path
    end
  end
  
  private

  def add_selected_products_to_cart
    selected_products = params[:selected_products].select { |_, v| v.present? }
    selected_products.each_with_index do |(_, variant_id), index|
      variant = Spree::Variant.find(variant_id)
  
      # Trouver le stock_movement correspondant au variant sélectionné et à la date
      stock_movement = Spree::StockMovement.find_by(stock_item_id: variant.stock_items.first.id, date: @selected_date)
  
      # Ajouter le produit au panier avec le numéro du produit, la date et le créneau horaire
      current_order.contents.add(variant, 1, product_number: index + 1, date: @selected_date, time_slot: stock_movement.time_slot)
  
      # Marquer le stock_movement comme réservé
      stock_movement.update(reserved: true)
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

  def time_slot_reserved?(date, time_slot)
    reserved_line_items = Spree::LineItem.where(date: date, time_slot: time_slot)

    reserved_line_items.any? do |line_item|
      line_item.product_id == @product.id
    end
  end
  helper_method :time_slot_reserved?

  def all_products_sold_out?(date)
    product_ids_with_available_variants = Spree::Variant.where(reserved: false).where("date(created_at) = ?", date).pluck(:product_id).uniq
    !product_ids_with_available_variants.include?(@product.id)
  end
  
  def available_on_date?(date)
    Spree::Variant.where(product_id: @product.id, reserved: false).where("date(created_at) = ?", date).exists?
  end
  helper_method :available_on_date?
  
  helper_method :all_products_sold_out?
end
