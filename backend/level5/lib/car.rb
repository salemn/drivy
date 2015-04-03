class Car

  attr_reader :price_per_day, :price_per_km

  def initialize(args)
    @price_per_day = args[:price_per_day]
    @price_per_km = args[:price_per_km]
  end
end