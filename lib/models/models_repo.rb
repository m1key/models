require 'net/http'
require 'json'

module Models

  class ModelsRepo

    def initialize(host, url, form_id, all_basic_models_payload, fetch_categories_payload, fetch_complete_model_payload,
                   fetch_category_with_basic_models_payload, fetch_price_for_configurations_payload)
      @host = host
      @url = url
      @all_basic_models_payload = all_basic_models_payload
      @fetch_categories_payload = fetch_categories_payload
      @fetch_complete_model_payload = fetch_complete_model_payload
      @fetch_category_with_basic_models_payload = fetch_category_with_basic_models_payload
      @fetch_price_for_configurations_payload = fetch_price_for_configurations_payload

      # @form_id = fetch_form_id
      @form_id = form_id
    end

    private def fetch_form_id
      body = fetch_response_body('/', nil)
      body.scan(/name="form_build_id" value="(.*?)" \/>/).first[0]
    end

    private def fetch_response_body(path, payload)
      cookie = ['disclaimerShow=1'].join('; ')
      req = Net::HTTP::Post.new(path, initheader = {'Content-Type' =>'application/x-www-form-urlencoded; charset=UTF-8',
                                                    'Cookie' => cookie})
      req.body = payload unless payload == nil
      begin
        response = Net::HTTP.new(@host, 80).start {|http| http.request(req) }
      rescue Net::ReadTimeout => e
        puts "WARN  Timeout [#{e}]. Retrying..."
        sleep 3
        response = Net::HTTP.new(@host, 80).start {|http| http.request(req) }
      rescue SocketError => e
        puts "WARN  SocketError [#{e}]. Retrying..."
        sleep 3
        response = Net::HTTP.new(@host, 80).start {|http| http.request(req) }
      end
      response.body
    end

    def fetch_all_basic_models
      begin
        payload = @all_basic_models_payload.gsub(/\[form_id\]/, @form_id)

        body = fetch_response_body(@url, payload)
        response_json = JSON.parse(body)

        line_with_select_replace = response_json.select{|row| row['method'] == 'replaceWith'}.first
        actual_data = line_with_select_replace['data']
        line_with_models = actual_data.lines[6]

        line_with_models.scan(/value="(\d+)">(.*?)</).reject{|match| match[1].strip.length == 0}.map{|match| Model.new(match[0], match[1].strip)}.sort_by{|model| model.name}
      rescue JSON::ParserError => e
        puts "Error while processing body: [#{body}]"
        puts e
        raise e
      end
    end

    def fetch_categories
      payload = @fetch_categories_payload.gsub(/\[form_id\]/, @form_id)

      body = fetch_response_body(@url, payload)
      response_json = JSON.parse(body)

      line_with_select_replace = response_json.select{|row| row['method'] == 'replaceWith'}.first
      actual_data = line_with_select_replace['data']
      line_with_categories = actual_data.lines[2]

      line_with_categories.scan(/value=".*?">(.*?)</).reject{|match| match[0].strip.length == 0}.map{|match| Category.new(nil, match[0].strip)}
    end

    def fetch_complete_model(model)
      payload = @fetch_complete_model_payload.gsub(/\[form_id\]/, @form_id).gsub(/\[model_id\]/, model.id)

      body = fetch_response_body(@url, payload)
      response_json = JSON.parse(body)

      updated_model = Model.new(model.id, model.name)

      line_with_category_container = response_json[3]
      actual_data = line_with_category_container['data']
      line_with_categories = actual_data.lines[2]
      updated_model.categories = line_with_categories.scan(/value="(\d+)">(.*?)</).reject{|match| match[1].strip.length == 0 or match[1] == '- Select -'}.map{|match| Category.new(match[0], match[1].strip)}

      line_with_model_data = response_json[7]
      if line_with_model_data then
        actual_model_data = line_with_model_data['data']
        line_with_country = actual_model_data.lines[0]
        updated_model.country_code = line_with_country.scan(/<span class="country-flag (.*?)">/).map{|match| Country.new(match[0])}
        updated_model.sold = line_with_country.scan(/<div class="custom-sold">Number of Sales : <strong>(\d+)<\/strong>/).map{|match| Sold.new(match[0])}
      else
        puts "WARN  No model data for #{model.name}!"
      end

      line_with_duration_container = response_json[4]
      actual_duration_data = line_with_duration_container['data']
      line_with_duration = actual_duration_data.lines[2]
      updated_model.duration_options = line_with_duration.scan(/value="(\d+)">(.*?)</).reject{|match| match[1].strip.length == 0 or match[1] == '- Select -'}.map{|match| Duration.new(match[0], match[1])}

      line_with_duration_container = response_json[5]
      actual_duration_data = line_with_duration_container['data']
      line_with_duration = actual_duration_data.lines[2]
      updated_model.quality_options = line_with_duration.scan(/value="(\d+)">(.*?)</).reject{|match| match[1].strip.length == 0 or match[1] == '- Select -'}.map{|match| Quality.new(match[0], match[1])}

      line_with_delivery_container = response_json[6]
      if line_with_delivery_container != nil then
        actual_delivery_data = line_with_delivery_container['data']
        line_with_delivery = actual_delivery_data.lines[2]
        updated_model.delivery_options = line_with_delivery.scan(/value="(\d+)">(.*?)</).reject{|match| match[1].strip.length == 0 or match[1] == '- Select -'}.map{|match| Delivery.new(match[0], match[1])}
      else
        puts "WARN  No delivery options for #{model.name}!"
      end

      updated_model
    end

    def fetch_category_with_basic_models(category)
      payload = @fetch_category_with_basic_models_payload.gsub(/\[form_id\]/, @form_id).gsub(/\[category_name\]/, category.name.gsub(/ /, '+'))

      body = fetch_response_body(@url, payload)
      response_json = JSON.parse(body)

      line_with_model_data = response_json[1]
      actual_model_data = line_with_model_data['data']
      line_with_models = actual_model_data.lines[2]
      models = line_with_models.scan(/value="(\d+)">(.*?)</).reject{|match| match[1].strip.length == 0}.map{|match| Model.new(match[0], match[1].strip)}

      updated_category = Category.new(category.id, category.name)
      updated_category.models = models
      updated_category
    end

    def fetch_price_for_configuration(configuration)
      payload = @fetch_price_for_configurations_payload.gsub(/\[form_id\]/, @form_id).gsub(/\[model_id\]/, configuration.model_id).gsub(/\[category_id\]/, configuration.category_id).gsub(/\[duration_id\]/, configuration.duration_id).gsub(/\[quality_id\]/, configuration.quality_id).gsub(/\[delivery_id\]/, configuration.delivery_id)

      body = fetch_response_body(@url, payload)
      response_json = JSON.parse(body)
      line_with_select_replace = response_json.select{|row| row['method'] == 'replaceWith'}.first
      actual_data = line_with_select_replace['data']
      amount = actual_data.scan(/<span id="change-price">(.*?)<\/span>/).first[0].gsub(/[^\d\.]/, '').to_f
      currency = actual_data.scan(/name="currencytype" value="(.*?)"\/>/).first[0]
      Price.new(amount, currency)
    end
  end
end