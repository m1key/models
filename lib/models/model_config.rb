module Models
  class ModelConfig
    attr_reader :model_id, :quality_id, :duration_id, :delivery_id, :category_id
    attr_accessor :price

    def initialize(model_id, category_id, delivery_id, quality_id, duration_id)
      @model_id = model_id
      @category_id = category_id
      @delivery_id = delivery_id
      @quality_id = quality_id
      @duration_id = duration_id
    end

    def to_s
      "Model Config #{model_id}: [C: #{category_id}] [De: #{delivery_id}] [Du: #{duration_id}] [Q: #{quality_id}] [P: #{price}]"
    end
  end
end