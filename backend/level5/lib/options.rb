class Options
  attr_reader :deductible_reduction

  def initialize (args)
    @deductible_reduction = args[:deductible_reduction]
  end

  def to_json
    return {"deductible_reduction" => deductible_reduction.to_i}
  end
end