require "json"
require "date"

def rental_duration_price(total_number_of_rental_days, price_per_day)
  rental_day_count = 1
  rental_days_price = 0
  while rental_day_count <= total_number_of_rental_days
    if (rental_day_count<=1)
      rental_days_price += price_per_day
    elsif (rental_day_count <=4)
      rental_days_price += price_per_day * 0.9
    elsif (rental_day_count <=10)
      rental_days_price += price_per_day * 0.7
    else
      rental_days_price += price_per_day * 0.5
    end
    rental_day_count = rental_day_count + 1
  end
  return rental_days_price
end

def rental_distance_price(distance, price_per_km)
  return distance * price_per_km
end

Duration = Struct.new(:start_date, :end_date) do
  def rental_duration
    start_date_value = Date.parse(start_date)
    end_date_value = Date.parse(end_date)
    raise ArgumentError.new("End date should be after start date") if end_date_value < start_date_value
    return end_date_value - start_date_value + 1
  end
end

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
    duration = Duration.new(rental_input["start_date"], rental_input["end_date"])
    number_of_rental_days = duration.rental_duration
    rental_price = rental_duration_price(number_of_rental_days, selected_car["price_per_day"]) + rental_distance_price(rental_input["distance"], selected_car["price_per_km"])
    rental["id"] = rental_input["id"]
    rental["price"] = rental_price.to_i
    rentals << rental
  else
    raise "the car with id=[#{rental_input["car_id"]}] does not exist!"
  end
end
File.open(File.join(data_files_directory_path, "output.json").to_s, "w") do |output_file|
  output_file.write(JSON.pretty_generate({"rentals" => rentals}))
end