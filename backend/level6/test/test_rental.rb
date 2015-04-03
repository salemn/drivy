require_relative "../lib/rental"
require_relative "../lib/car"
require_relative "../lib/options"
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

  def test_rental_price_result_more_ten_days
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

  def test_deductible_reduction_value_option_activated
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-8", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120), :options => Options.new(:deductible_reduction => true))
    result = rental.deductible_reduction
    assert_equal(400, result)
  end

  def test_deductible_reduction_value_option_not_activated
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-8", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120), :options => Options.new(:deductible_reduction => false))
    result = rental.deductible_reduction
    assert_equal(0, result)
  end

  def test_rental_information_summary_without_deduction
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-8", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120), :options => Options.new(:deductible_reduction => false))
    result = rental.rental_cost_detail_summary
    expected = {"id" => 1, "price" => 12100, "options" => {"deductible_reduction" => 0}, "commission" => {"insurance_fee" => 1815, "assistance_fee" => 100, "drivy_fee" => 1715}}
    assert_equal(result, expected)
  end

  def test_rental_information_summary_with_deduction_reduction
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-8", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120), :options => Options.new(:deductible_reduction => true))
    result = rental.rental_cost_detail_summary
    expected = {"id" => 1, "price" => 12100, "options" => {"deductible_reduction" => 400}, "commission" => {"insurance_fee" => 1815, "assistance_fee" => 100, "drivy_fee" => 1715}}
    assert_equal(result, expected)
  end

  def test_rental_debit_credit_summary_with_deduction_reduction
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-8", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120), :options => Options.new(:deductible_reduction => true))
    result = rental.rental_debit_credit_summary
    expected = {"id" => 1, "actions" => [
        {"who" => "driver", "type" => "debit", "amount" => 12500},
        {"who" => "owner", "type" => "credit", "amount" => 8470},
        {"who" => "insurance", "type" => "credit", "amount" => 1815},
        {"who" => "assistance", "type" => "credit", "amount" => 100},
        {"who" => "drivy", "type" => "credit", "amount" => 2115}]}

    assert_equal(result, expected)
  end

  def test_rental_debit_credit_summary_without_deduction_reduction
    rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                        :end_date => "2015-12-8", :distance => 100, :car => Car.new(:price_per_day => 100, :price_per_km => 120), :options => Options.new(:deductible_reduction => false))
    result = rental.rental_debit_credit_summary
    expected = {"id" => 1, "actions" => [
        {"who" => "driver", "type" => "debit", "amount" => 12100},
        {"who" => "owner", "type" => "credit", "amount" => 8470},
        {"who" => "insurance", "type" => "credit", "amount" => 1815},
        {"who" => "assistance", "type" => "credit", "amount" => 100},
        {"who" => "drivy", "type" => "credit", "amount" => 1715}]}

    assert_equal(result, expected)
  end

end