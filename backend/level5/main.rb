require "json"
require_relative "lib/car"
require_relative "lib/rental"
require_relative "lib/options"

data_files_directory_path = File.expand_path(File.dirname(__FILE__))
json_data = File.read(File.join(data_files_directory_path, "data.json").to_s)
rentals_inputs = JSON.parse(json_data)
cars={}
rentals_inputs["cars"].each do |car|
  cars[car["id"]] = Car.new(:price_per_day => car["price_per_day"], :price_per_km => car["price_per_km"])
end
rentals = Array.new
rentals_inputs["rentals"].each do |rental_input|
  if cars.has_key?(rental_input["car_id"])
    selected_car = cars[rental_input["car_id"]]
    rental = Rental.new(:id => rental_input["id"], :start_date =>rental_input["start_date"],
                        :end_date => rental_input["end_date"], :distance => rental_input["distance"], :car => selected_car, :options => Options.new(:deductible_reduction => rental_input["deductible_reduction"]))

    rentals << rental.rental_debit_credit_summary
  end
end
File.open(File.join(data_files_directory_path, "output.json").to_s,"w+") do |output_file|
  output_file.write(JSON.pretty_generate({ "rentals" =>rentals}))
end