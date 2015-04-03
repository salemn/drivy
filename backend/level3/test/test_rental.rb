require_relative "../lib/rental"
require_relative "../lib/car"
require "test/unit"
require 'date'

class Test_Rental < Test::Unit::TestCase

  def test_rental_price_result_invalid_dates
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-7", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120))
    exception = assert_raise(ArgumentError) { rental.rental_price }
    assert_equal("End date should be after start date for rental id=[1]", exception.message)
  end

  def test_rental_price_result_one_day
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-8", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120))
    result = rental.rental_price
    assert_equal(12100, result)
  end

  def test_rental_price_result_between_one__and_four_days
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-10", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120))
    result = rental.rental_price
    assert_equal(12280, result)
  end

  def test_rental_price_result_between_four_and_ten_days
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-14", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120))
    result = rental.rental_price
    assert_equal(12580, result)
  end

  def test_rental_price_result_more_than_ten_days
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-19", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120))
    result = rental.rental_price
    assert_equal(12890, result)
  end

  def test_rental_fee_result
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-19", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120))
    result = rental.rental_commission
    assert_equal(1933.5, result.insurance_fee.to_f)
  end
end