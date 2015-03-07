require 'neo4j-core'

module Models
  
  class Neo4jAccess

    MERGE_MODEL = 'MERGE (model:Model { id:{id}, name:{name} })'\
      ' ON CREATE SET model.created = timestamp()'\
      ' RETURN model.name as name, model.id as id'

    MERGE_MODEL_AND_DURATION = 'MATCH (model:Model { id:{id} })'\
      ' MERGE (duration:Duration {value: {duration}})' \
      ' MERGE (model_duration:ModelDuration {id: {duration_id}})' \
      ' CREATE UNIQUE (model)-[r1:LASTS1]->(model_duration)-[r2:LASTS2]->(duration) RETURN r1'

    MERGE_MODEL_AND_QUALITY = 'MATCH (model:Model { id:{id} })'\
      ' MERGE (quality:Quality {value: {quality}})' \
      ' MERGE (model_quality:ModelQuality {id: {quality_id}})' \
      ' CREATE UNIQUE (model)-[r1:PRODUCES1]->(model_quality)-[r2:PRODUCES2]->(quality) RETURN r1'

    MERGE_MODEL_AND_DELIVERY = 'MATCH (model:Model { id:{id} })'\
      ' MERGE (delivery:Delivery {value: {delivery}})' \
      ' MERGE (model_delivery:ModelDelivery {id: {delivery_id}})' \
      ' CREATE UNIQUE (model)-[r1:DELIVERS1]->(model_delivery)-[r2:DELIVERS2]->(delivery) RETURN r1'

    MERGE_MODEL_AND_CATEGORY = 'MATCH (model:Model { id:{id} })'\
      ' MERGE (category:Category {name: {category_name}})' \
      ' MERGE (model_category:ModelCategory {id: {category_id}})' \
      ' CREATE UNIQUE (model)-[r1:DOES1]->(model_category)-[r2:DOES2]->(category) RETURN r1'

    MERGE_CATEGORY = 'MERGE (category:Category { name:{name} })'\
      ' ON CREATE SET category.created = timestamp()'\
      ' RETURN category.name as name, category.id as id'

    MERGE_CATEGORY_AND_MODEL = 'MATCH (category:Category { name:{name} })'\
      ' MATCH(model:Model { id:{model_id} })'\
      ' CREATE UNIQUE (category)<-[r:DOES]-(model) RETURN r'

    GET_MODEL_CONFIG = 'MATCH (model:Model {id: {id} })-[:DOES1]->(model_category:ModelCategory)-[:DOES2]->(category: Category {name: {category_name} })' \
      ' MATCH (model)-[:DELIVERS1]-(model_delivery:ModelDelivery)-[:DELIVERS2]->(delivery:Delivery)' \
      ' MATCH (model)-[:PRODUCES1]-(model_quality:ModelQuality)-[:PRODUCES2]->(quality:Quality)' \
      ' MATCH (model)-[:LASTS1]-(model_duration:ModelDuration)-[:LASTS2]->(duration:Duration)' \
      ' RETURN model_category.id as model_category, model_delivery.id as delivery_id, delivery.value as delivery_name, model_quality.id as quality_id, quality.value as quality_name, model_duration.id as duration_id, duration.value as duration_name'

    ALL_CATEGORIES = 'MATCH (category:Category) RETURN category.name as name ORDER BY category.name ASC '

    ALL_MODELS = 'MATCH (model:Model) RETURN model.name as name, model.id as id ORDER BY model.name ASC '

    MODELS_BY_CATEGORY = 'MATCH (category:Category { name:{name} })<-[r:DOES]-(model:Model) '\
      ' RETURN model.name as name, model.id as id ORDER BY model.name ASC'

    MERGE_CONFIG = 'MATCH (model:Model {id: {model_id}})'\
      ' MATCH (model_category:ModelCategory {id: {category_id}})'\
      ' MATCH (model_delivery:ModelDelivery {id: {delivery_id}})'\
      ' MATCH (model_duration:ModelDuration {id: {duration_id}})'\
      ' MATCH (model_quality:ModelQuality {id: {quality_id}})'\
      ' MERGE (price:Price {amount: {price_amount}, currency: {price_currency}, key: {price_key}})'\
      ' MERGE (product:Product {key: {product_key}})'\
      ' CREATE UNIQUE (product)-[:IS_BY]->(model)'\
      ' CREATE UNIQUE (product)-[:IS_OF_CATEGORY]->(model_category)'\
      ' CREATE UNIQUE (product)-[:DELIVERS_IN]->(delivery)'\
      ' CREATE UNIQUE (product)-[:LASTS]->(duration)'\
      ' CREATE UNIQUE (product)-[:IS_OF_QUALITY]->(quality)'\
      ' CREATE UNIQUE (product)-[:COSTS]->(price)'\
      ' RETURN product'\

    def initialize(delivery_options_map, quality_options_map, duration_options_map)
      puts 'Opening Neo4j session...'
      @session = Neo4j::Session.open(:server_db)
      puts 'Session opened.'
      @delivery_options_map = delivery_options_map
      @quality_options_map = quality_options_map
      @duration_options_map = duration_options_map
    end

    def save_basic_model(model)
      saved_node = Neo4j::Session.
          query(MERGE_MODEL, id: model.id, name: model.name).first

      saved_model = Model.new(saved_node[:id], saved_node[:name])

      raise "Saved model [#{saved_model}] key does not match expectations of model to save [#{model}]." if saved_model.id != model.id
      return saved_model
    end

    def save_complete_model(model)
      unless model.duration_options == nil then model.duration_options.each{|duration| Neo4j::Session.query(MERGE_MODEL_AND_DURATION, id: model.id, duration: duration.value, duration_id: duration.id) } end
      unless model.quality_options == nil then model.quality_options.each{|quality| Neo4j::Session.query(MERGE_MODEL_AND_QUALITY, id: model.id, quality: quality.value, quality_id: quality.id) } end
      unless model.delivery_options == nil then model.delivery_options.each{|delivery| Neo4j::Session.query(MERGE_MODEL_AND_DELIVERY, id: model.id, delivery: delivery.value, delivery_id: delivery.id) } end
      unless model.categories == nil then model.categories.each{|category| Neo4j::Session.query(MERGE_MODEL_AND_CATEGORY, id: model.id, category_name: category.name, category_id: category.id) } end
    end

    def save_category_with_basic_models(category)
      saved_node = Neo4j::Session.
          query(MERGE_CATEGORY, name: category.name).first

      saved_category = Category.new(saved_node[:id], saved_node[:name])

      raise "Saved category [#{saved_category}] key does not match expectations of category to save [#{category}]." if saved_category.name != category.name
      
      category.models.each {|model| Neo4j::Session.query(MERGE_CATEGORY_AND_MODEL, name: category.name, model_id: model.id) }
      
      return saved_category
    end

    def get_categories_with_basic_models
      categories = Neo4j::Session.query(ALL_CATEGORIES).map{|category| Category.new(nil, category[:name]) }
      categories.each do |category|
        category.models = Neo4j::Session.query(MODELS_BY_CATEGORY, name: category.name).map{|model| Model.new(model[:id], model[:name]) }
      end
    end

    def close
      @session.close
    end

    def get_highest_config(model, category)
      model_config = Neo4j::Session.query(GET_MODEL_CONFIG, id: model.id, category_name: category.name)
      if model_config.first == nil
        puts "WARN  No config for #{model.name} for category #{category.name}."
        return nil
      end

      quickest_delivery_for_model = highest(model, model_config.map{|row| Delivery.new(row[:delivery_id], row[:delivery_name])}.uniq, @delivery_options_map)
      highest_quality_for_model = highest(model, model_config.map{|row| Quality.new(row[:quality_id], row[:quality_name])}.uniq, @quality_options_map)
      highest_duration_for_model = highest(model, model_config.map{|row| Duration.new(row[:duration_id], row[:duration_name])}.uniq, @duration_options_map)
      ModelConfig.new(model.id, model_config.first[:model_category], quickest_delivery_for_model, highest_quality_for_model, highest_duration_for_model)
    end

    def highest(model, model_options, options_map)
      unless model_options == nil or model_options.size == 0 then
        begin
          model_options.map{|model_delivery_option| [model_delivery_option, options_map[model_delivery_option.value]]}.sort_by{|option| option[1]}.first[0].id
        rescue ArgumentError => e
          puts "#{e} for [#{model_options}] Anything missing from the config.yaml file?"
        rescue NoMethodError => e
          puts "#{e} for [#{model_options}]"
        end
      else
        puts "WARN  Model options null or empty for [#{model.name}]."
      end
    end

    def get_basic_models
      Neo4j::Session.query(ALL_MODELS).map{|model| Model.new(model[:id], model[:name]) }
    end

    def save_config(config)
      product_key = "#{config.model_id}___#{config.category_id}___#{config.delivery_id}___#{config.duration_id}___#{config.quality_id}___#{config.delivery_id}"
      product = Neo4j::Session.query(MERGE_CONFIG, model_id: config.model_id, category_id: config.category_id,
          delivery_id: config.delivery_id, duration_id: config.duration_id, quality_id: config.quality_id,
          price_amount: config.price.amount, price_currency: config.price.currency,
          price_key: "#{config.price.amount}___#{config.price.currency}",
          product_key: product_key).first[0]

      raise "Saved product key [#{product[:key]}] does not match expectations of key to save [#{product_key}]." unless product[:key] == product_key
      product
    end

  end

end