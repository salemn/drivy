require_relative "../main"
require "test/unit"
require 'date'

class TestMain< Test::Unit::TestCase

  def test_rental_duration_invalid_dates
    duration = Duration.new("2015-12-8", "2015-12-7")
    exception = assert_raise(ArgumentError) { duration.rental_duration }
    assert_equal("End date should be after start date", exception.message)
  end

  def test_rental_duration_price_result_one_day
    result = rental_duration_price(1, 100)
    assert_equal(100, result)
  end

  def test_rental_duration_price_result_between_one__and_four_days
    result = rental_duration_price(3, 100)
    assert_equal(280, result)
  end

  def test_rental_duration_price_result_between_four_and_ten_days
    result = rental_duration_price(7, 100)
    assert_equal(580, result)
  end

  def test_rental_duration_price_result_more_ten_days
    result = rental_duration_price(12, 100)
    assert_equal(890, result)
  end

  def test_rental_duration_correct_dates
    result = Duration.new("2015-12-8", "2015-12-18").rental_duration
    assert_equal(11, result)
  end

end