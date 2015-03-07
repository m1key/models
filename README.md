# Models

Just playing with Neo4j. Analyse models and categories data.

## Installation

> CREATE CONSTRAINT ON (model:Model) ASSERT model.id IS UNIQUE
> CREATE CONSTRAINT ON (category:Category) ASSERT category.name IS UNIQUE
> CREATE CONSTRAINT ON (duration:Duration) ASSERT duration.value IS UNIQUE
> CREATE CONSTRAINT ON (delivery:Delivery) ASSERT delivery.value IS UNIQUE
> CREATE CONSTRAINT ON (quality:Quality) ASSERT quality.value IS UNIQUE
> CREATE CONSTRAINT ON (model_duration:ModelDuration) ASSERT model_duration.id IS UNIQUE
> CREATE CONSTRAINT ON (model_quality:ModelQuality) ASSERT model_quality.id IS UNIQUE
> CREATE CONSTRAINT ON (model_delivery:ModelDelivery) ASSERT model_delivery.id IS UNIQUE
> CREATE CONSTRAINT ON (model_category:ModelCategory) ASSERT model_category.id IS UNIQUE
> CREATE CONSTRAINT ON (product:Product) ASSERT product.key IS UNIQUE

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install models

## Usage

Most popular categories:

> MATCH(category:Category)<-[r:DOES]-(model:Model) RETURN category.name, count(model) ORDER BY count(model) DESC

Least popular categories:

> MATCH(category:Category)<-[r:DOES]-(model:Model) RETURN category.name, count(model) ORDER BY count(model) ASC

Most specialised models:

> MATCH (model:Model)-[r:DOES]->(category:Category) RETURN model.name, count(r) ORDER BY count(r) ASC LIMIT 10

Least specialised models:

> MATCH (model:Model)-[r:DOES]->(category:Category) RETURN model.name, count(r) ORDER BY count(r) DESC LIMIT 10

Sample model:

> MATCH (model:Model {name:"..."})-[r]-(a) RETURN model, r, a

Total model count:

> MATCH (model:Model) RETURN count(model)

Models per category:

> MATCH (category:Category {name:"..."})<-[:DOES]-(model:Model) RETURN count(model)

Model and intermediate and actual values

    > MATCH (model:Model {name: "..."})-[r1]-(intermediate)-[r2]->actual RETURN model, r1, intermediate, r2, actual

Model and categories

> MATCH (model:Model {name: "..."})-[r:DOES]->(category:Category) RETURN model, r, category

Model and intermediate and actual categories

> MATCH (model:Model {name: "..."})-[r1:DOES1]->(model_category:ModelCategory)-[r2:DOES2]->(category:Category) RETURN model, r1, model_category, r2, category

Most expensive products

> MATCH (price:Price)-[:COSTS]-(product:Product)-[:IS_BY]->(model:Model)
> MATCH (product)-[:IS_OF_CATEGORY]->(model_category:ModelCategory)-[:DOES2]->(category:Category) RETURN price.amount, model.name, category.name ORDER BY price.amount DESC LIMIT 10

Average price

> MATCH (price:Price)-[:COSTS]-(product:Product)-[:IS_OF_CATEGORY]->(model_category:ModelCategory)-[:DOES2]->(category:Category) RETURN avg(price.amount)

Most expensive products per category

> MATCH (price:Price)-[:COSTS]-(product:Product)-[:IS_BY]->(model:Model)
> MATCH (product)-[:IS_OF_CATEGORY]->(model_category:ModelCategory)-[:DOES2]->(category:Category {name: "..."}) RETURN price.amount, model.name, category.name ORDER BY price.amount DESC LIMIT 10

Most expensive categories

> MATCH (price:Price)-[:COSTS]-(product:Product)-[:IS_OF_CATEGORY]->(model_category:ModelCategory)-[:DOES2]->(category:Category) RETURN avg(price.amount) as average, category.name ORDER BY average DESC LIMIT 20

Most popular categories

> MATCH (category:Category)<-[r:DOES]-(:Model) RETURN category.name, count(r) as count ORDER BY count DESC

Largest difference between two categories

> MATCH (price1:Price)-[:COSTS]-(product1:Product)-[:IS_BY]->(model:Model)
> MATCH (product1)-[:IS_OF_CATEGORY]->(model_category1:ModelCategory)-[:DOES2]->(category1:Category {name: "..."})
> MATCH (price2:Price)-[:COSTS]-(product2:Product)-[:IS_BY]->(model:Model)
> MATCH (product2)-[:IS_OF_CATEGORY]->(model_category2:ModelCategory)-[:DOES2]->(category2:Category {name: "..."})
> RETURN price1.amount, price2.amount, (price1.amount - price2.amount) as difference, model.name ORDER BY ABS(difference) DESC LIMIT 10

Largest difference between one category and other categories

> MATCH (price1:Price)-[:COSTS]-(product1:Product)-[:IS_BY]->(model:Model)
> MATCH (product1)-[:IS_OF_CATEGORY]->(:ModelCategory)-[:DOES2]->(category1:Category {name: "..."})
> MATCH (price2:Price)-[:COSTS]-(:Product)-[:IS_BY]->(model)
> WITH price1, min(price2.amount) as min, model, category1
> MATCH (price2:Price)<-[:COSTS]-(product:Product)-[:IS_BY]->(model) WHERE price2.amount=min
> MATCH (product)-[:IS_OF_CATEGORY]->(:ModelCategory)-[:DOES2]->(category2:Category)
> WITH price1, price2, model, category1, category2
> RETURN price1.amount, category1.name, price2.amount, collect(category2.name), (price1.amount - price2.amount) as difference, model.name ORDER BY difference DESC LIMIT 10

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
