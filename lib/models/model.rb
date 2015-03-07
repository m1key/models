module Models
  
  class Model

    attr_accessor :name
    attr_accessor :categories
    attr_accessor :country_code
    attr_accessor :sold
    attr_accessor :duration_options
    attr_accessor :quality_options
    attr_accessor :delivery_options
    attr_reader :id

    def initialize(id, name)
      @id = id
      @name = name
    end

    def to_s
      "Model #{id}: #{name} [Sold: #{sold}] [DeO: #{delivery_options}] [QO: #{quality_options}] [DuO: #{duration_options}] [CC: #{country_code}] [Categories: #{categories}]"
    end

    def ==(another_model)
      self.id == another_model.id
    end
    
  end
  
end