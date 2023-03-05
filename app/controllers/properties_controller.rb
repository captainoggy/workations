class PropertiesController < ApplicationController
  inertia_share do
    {
      accountLinks: helpers.account_links,
      primaryLinks: helpers.primary_links
    }
  end

  def index
    render inertia: 'Properties/Index', props: {
      locations: locations.as_json(
        only: [ :id, :title, :description ]
      ),
      properties: properties.as_json(
        only: [
          :id,
          :title,
          :beds,
          :baths,
          :rating,
          :review_count,
          :price,
          :image_url,
          :location_id
        ]
      )
    }
  end

  def new
    render inertia: 'Properties/New', props: {
      locations: Location.all.as_json(only: [:id, :title])
    }
  end

  def create
    @property ||= Property.new(
      property_params.merge(
        review_count: 0,
        rating: 0,
        image_url: example_images.sample
      )
    )

    if @property.save
      redirect_to properties_path, notice: 'Property was successfully created.'
    else
      session[:errors] = @property.errors
      redirect_to new_property_path, alert: 'Property cannot be saved!'
    end
  end

  private

  def properties
    @properties ||= Property.
                    search_for_keywords(params[:keywords]).
                    search_for_beds(params[:beds]).
                    search_for_baths(params[:baths]).
                    search_for_price(params[:price])
  end

  def locations
    @locations ||= Location.
                   where(id: properties.map(&:location_id).uniq)
  end

  def property_params
    params.require(:property).permit(:title, :beds, :baths, :price, :location_id)
  end

  def example_images
    [
      'https://images.unsplash.com/photo-1449844908441-8829872d2607?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1510627489930-0c1b0bfb6785?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1527030280862-64139fba04ca?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=80'
    ]
  end
end
