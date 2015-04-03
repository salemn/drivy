class Action
  attr_reader :who, :action_type, :amount

  def initialize(who, action_type, amount)
    @who = who
    @action_type = action_type
    @amount = amount
  end

  def to_json
    return {"who" => @who.to_s, "type" => @action_type.to_s, "amount" => @amount.to_i}
  end

end