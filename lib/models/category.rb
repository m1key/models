module Models

  class Category

    attr_accessor :id
    attr_accessor :name
    attr_accessor :models
  
    def initialize(id, name)
      @id = id
      @name = name
    end
  
    def to_s
      "Category #{id}: #{name} [Models: #{models}]"
    end
  
    def ==(another_category)
      self.name == another_category.name
    end
  
  end

end
