require_relative "../lib/rental_modification"
require_relative "../lib/rental"
require_relative "../lib/car"
require_relative "../lib/options"
require 'test/unit'

class Test_Rental_Modification < Test::Unit::TestCase

  def test_no_changes_nil_values
    initial_rental = Rental.new(:id => nil, :start_date => nil,
                                :end_date => nil, :distance => 12, :car => nil, :options => nil)
    rental_modification = Rental_Modification.new(:start_date => nil,:end_date => nil, :distance => nil, :rental => initial_rental)
    changes_happened = rental_modification.changes_happened
    assert_equal(false, changes_happened)
  end

  def test_no_changes_nil_start_date
    initial_rental = Rental.new(:id => nil, :start_date => nil,
                                :end_date => "2015-12-8", :distance => 12, :car => nil, :options => nil)
    rental_modification = Rental_Modification.new(:start_date => nil,:end_date => "2015-12-8", :distance => 12, :rental => initial_rental)
    changes_happened = rental_modification.changes_happened
    assert_equal(false, changes_happened)
  end

  def test_no_changes_nil_end_date
    initial_rental = Rental.new(:id => nil, :start_date => "2015-12-8",
                                :end_date => nil, :distance => 12, :car => nil, :options => nil)
    rental_modification = Rental_Modification.new(:start_date => "2015-12-8",:end_date => nil, :distance => 12, :rental => initial_rental)
    changes_happened = rental_modification.changes_happened
    assert_equal(false, changes_happened)
  end

  def test_no_changes_nil_distance
    initial_rental = Rental.new(:id => nil, :start_date => "2015-12-8",
                                :end_date => "2015-12-8", :distance => nil, :car => nil, :options => nil)
    rental_modification = Rental_Modification.new(:start_date => "2015-12-8",:end_date => "2015-12-8", :distance => nil, :rental => initial_rental)
    changes_happened = rental_modification.changes_happened
    assert_equal(false, changes_happened)
  end

  def test_no_changes_same_values
    initial_rental = Rental.new(:id => nil, :start_date => "2015-12-8",
                                :end_date => "2015-12-8", :distance => 12, :car => nil, :options => nil)
    rental_modification = Rental_Modification.new(:start_date => "2015-12-8",:end_date => "2015-12-8", :distance => 12, :rental => initial_rental)
    changes_happened = rental_modification.changes_happened
    assert_equal(false, changes_happened)
  end

  def test_compute_modification_with_end_date_change
    initial_rental = Rental.new(:id => 1, :start_date => "2015-12-8",
                                :end_date => "2015-12-8", :distance => 100, :car => Car.new(:price_per_day => 2000, :price_per_km => 10), :options => Options.new(:deductible_reduction => true))
    rental_modification = Rental_Modification.new(:id => 1, :start_date => nil,:end_date => "2015-12-10", :distance => 150, :rental => initial_rental)
    result = rental_modification.compute_modification
    expected = {"id"=>1,
                "rental_id"=>1,
                "actions"=>[
                  {"who" => "driver", "type" => "debit", "amount" => 4900},
                  {"who" => "owner", "type" => "credit", "amount" => 2870},
                  {"who" => "insurance", "type" => "credit", "amount" => 615},
                  {"who" => "assistance", "type" => "credit", "amount" => 200},
                  {"who" => "drivy", "type" => "credit", "amount" => 1215}]
    }
    assert_equal(expected,result)
  end

  def test_compute_modification_with_start_date_change
    initial_rental = Rental.new(:id => 1, :start_date => "2015-07-3",
                                :end_date => "2015-07-14", :distance => 1000, :car => Car.new(:price_per_day => 2000, :price_per_km => 10), :options => Options.new(:deductible_reduction => true))
    rental_modification = Rental_Modification.new(:id => 1, :start_date => "2015-07-04",:end_date => nil, :distance => nil, :rental => initial_rental)
    result = rental_modification.compute_modification
    expected = {"id"=>1,
                "rental_id"=>1,
                "actions"=> [
                    {"who" => "driver", "type" => "credit", "amount" => 1400},
                    {"who" => "owner", "type" => "debit", "amount" => 700},
                    {"who" => "insurance", "type" => "debit", "amount" => 150},
                    {"who" => "assistance", "type" => "debit", "amount" => 100},
                    {"who" => "drivy", "type" => "debit", "amount" => 450}]
    }
    assert_equal(expected,result)
  end

end