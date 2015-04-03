require_relative "action"

class Rental_Modification

  attr_reader :id, :start_date, :end_date, :distance, :rental

  def initialize(args)
    @id = args[:id]
    @start_date = args[:start_date]
    @end_date = args[:end_date]
    @distance = args[:distance]
    @rental = args[:rental]
  end

  def changes_happened
    if (!dates_changed && (@distance.nil? || @distance == @rental.distance))
      return false
    else
      return true
    end

  end

  def dates_changed
    if (@start_date == nil && @end_date == nil)
      return false
    elsif (@start_date != @rental.start_date || @start_date != @rental.start_date)
      return true
    end
  end

  def compute_modification
    if (changes_happened)
      actions = []
      modified_rental = apply_change
      if (modified_rental.rental_price > @rental.rental_price)
        actions.push(*compute_actions("debit", "credit", @rental, modified_rental))
      else
        actions.push(*compute_actions("credit", "debit", modified_rental, @rental))
      end
      return {"id" => @id, "rental_id" => @rental.id, "actions" => actions}
    end
  end

  def compute_actions(driver_action, payee_action, current_rental, modified_rental)
    actions = []
    actions << Action.new("driver", driver_action, modified_rental.paid_price - current_rental.paid_price).to_json
    actions << Action.new("owner", payee_action, modified_rental.owner_fee - current_rental.owner_fee).to_json
    actions << Action.new("insurance", payee_action, modified_rental.rental_commission.insurance_fee - current_rental.rental_commission.insurance_fee).to_json
    if (dates_changed)
      actions << Action.new("assistance", payee_action, modified_rental.rental_commission.assistance_fee - current_rental.rental_commission.assistance_fee).to_json
    end
    actions << Action.new("drivy", payee_action, (modified_rental.rental_commission.drivy_fee + modified_rental.deductible_reduction) - (current_rental.rental_commission.drivy_fee + current_rental.deductible_reduction)).to_json
    return actions
  end


  def apply_change

    rental = Rental.new(:id => @rental.id, :start_date =>  @start_date == nil ? @rental.start_date : @start_date,
                        :end_date =>  @end_date == nil ? @rental.end_date : @end_date, :distance =>  @distance == nil ? @rental.distance : @distance, :car => @rental.car, :options => @rental.options)
    return rental
  end

end