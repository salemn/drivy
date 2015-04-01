require "json"
require "date"
data_files_directory_path = File.expand_path(File.dirname(__FILE__))
json_data = File.read(File.join(data_files_directory_path, "data.json").to_s)
rentals_inputs = JSON.parse(json_data)
cars={}
rentals_inputs["cars"].each do |car|
  cars[car["id"]] = car
end
rentals = Array.new
rentals_inputs["rentals"].each do |rental_input|
  if cars.has_key?(rental_input["car_id"])
    selected_car = cars[rental_input["car_id"]]
    rental = {}
    rental_end_date = Date.parse(rental_input["end_date"])
    rental_start_date = Date.parse(rental_input["start_date"])
    raise "End date should be after start date for rental id=[#{rental_input["id"]}]" if rental_end_date < rental_start_date
    number_of_rental_days =  (rental_end_date - rental_start_date)  + 1
    rental_price = number_of_rental_days * selected_car["price_per_day"] + rental_input["distance"] * selected_car["price_per_km"]
    rental["id"] = rental_input["id"]
    rental["price"] = rental_price.to_i
    rentals << rental
  else
    raise "the car with id=[#{rental_input["car_id"]}] does not exist!"
  end
end
File.open(File.join(data_files_directory_path, "output.json").to_s,"w") do |output_file|
  output_file.write(JSON.pretty_generate({ "rentals" =>rentals}))
end
