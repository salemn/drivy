require 'date'
require_relative 'rental_commission'

class Rental
  attr_reader :id, :start_date, :end_date, :distance, :car, :option

  def initialize(args)
    @id = args[:id]
    @start_date = args[:start_date]
    @end_date = args[:end_date]
    @distance = args[:distance]
    @car = args[:car]
    @option = args[:option]
  end

  def rental_price
    return rental_duration_price + rental_distance_price
  end

  def rental_commission
    total_fee = rental_price * 0.3
    insurance_fee = total_fee * 0.5
    assistance_fee = total_rental_days * 100
    drivy_fee = total_fee - (insurance_fee + assistance_fee)
    return RentalCommission.new(insurance_fee, assistance_fee, drivy_fee)
  end

  private

  def total_rental_days
    rental_end_date = Date.parse(@end_date)
    rental_start_date = Date.parse(@start_date)
    raise ArgumentError.new("End date should be after start date for rental id=[#{@id}]") if rental_end_date < rental_start_date
    return (rental_end_date - rental_start_date) + 1
  end

  def rental_duration_price
    number_of_rental_days = total_rental_days
    rental_day_count = 1
    rental_days_price = 0
    while rental_day_count <= number_of_rental_days
      if (rental_day_count<=1)
        rental_days_price += @car.price_per_day
      elsif (rental_day_count <=4)
        rental_days_price += @car.price_per_day * 0.9
      elsif (rental_day_count <=10)
        rental_days_price += @car.price_per_day * 0.7
      else
        rental_days_price += @car.price_per_day * 0.5
      end
      rental_day_count = rental_day_count + 1
    end
    return rental_days_price
  end

  def rental_distance_price
    return @distance * @car.price_per_km
  end

end