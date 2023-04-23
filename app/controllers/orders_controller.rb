# frozen_string_literal: true

class OrdersController < StoreController
  helper 'spree/products', 'orders'

  respond_to :html

  before_action :store_guest_token

  def show
    @order = Spree::Order.find_by!(number: params[:id])
    authorize! :show, @order, cookies.signed[:guest_token]
  end

  def populate
    variant_ids = params[:variant_id]
    quantities = params[:quantity].map(&:to_i)
    product_id = params[:product_id]
  
    order = current_order || Spree::Order.new(order_params)
  
    variant_ids.each_with_index do |variant_id, index|
      variant = Spree::Variant.find(variant_id)
      quantity = quantities[index]
      options = params[:options] || {}
  
      line_item = order.contents.add(variant, quantity, options)
    end
  
    if order.save
      respond_with(order) do |format|
        format.html { redirect_to product_path(product_id) } # Modifié ici
        format.js { render :populate }
      end
    else
      flash[:error] = t('spree.unable_to_add_product')
      respond_with(order) do |format|
        format.html { redirect_to :back }
        format.js { render :populate }
      end
    end
  end
  

  private

  def store_guest_token
    cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
  end

  def order_params
    {
      user_id: spree_current_user&.id,
      store_id: current_store.id,
      currency: current_currency,
      guest_token: cookies.signed[:guest_token]
    }
  end

  def current_currency
    "USD" # Remplacez par la devise souhaitée
  end
end
