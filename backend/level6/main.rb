require "json"
require_relative "lib/car"
require_relative "lib/rental"
require_relative "lib/options"
require_relative "lib/rental_modification"

data_files_directory_path = File.expand_path(File.dirname(__FILE__))
json_data = File.read(File.join(data_files_directory_path, "data.json").to_s)
rentals_inputs = JSON.parse(json_data)
cars={}
rentals_inputs["cars"].each do |car|
  cars[car["id"]] = Car.new(:price_per_day => car["price_per_day"], :price_per_km => car["price_per_km"])
end
rentals = {}
rentals_inputs["rentals"].each do |rental_input|
  if cars.has_key?(rental_input["car_id"])
    selected_car = cars[rental_input["car_id"]]
    rental = Rental.new(:id => rental_input["id"], :start_date => rental_input["start_date"],
                        :end_date => rental_input["end_date"], :distance => rental_input["distance"], :car => selected_car, :options => Options.new(:deductible_reduction => rental_input["deductible_reduction"]))

    rentals[rental.id] = rental
  end
end
rentals_modification = Array.new
rentals_inputs["rental_modifications"].each do |rental_modification|
  if rentals.has_key?(rental_modification["rental_id"])
    selected_rental = rentals[rental_modification["rental_id"]]
    rental_modification = Rental_Modification.new(:id => rental_modification["id"], :start_date => rental_modification["start_date"],
                                                  :end_date => rental_modification["end_date"], :distance => rental_modification["distance"], :rental => selected_rental)

    rentals_modification << rental_modification.compute_modification
  end
end

File.open(File.join(data_files_directory_path, "output.json").to_s, "w") do |output_file|
  output_file.write(JSON.pretty_generate({"rental_modifications" => rentals_modification}))
end