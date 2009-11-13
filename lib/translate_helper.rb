module TranslateHelper
  def simple_filter(labels, param_name = 'filter', selected_value = nil)
    selected_value ||= params[param_name]
    filter = []
    labels.each do |item|
      if item.is_a?(Array)
        type, label = item
      else
        type = label = item
      end
      if type.to_s == selected_value.to_s
        filter << "<i>#{label}</i>"
      else
        link_params = params.merge({param_name.to_s => type})
        link_params.merge!({"page" => nil}) if param_name.to_s != "page"
        filter << link_to(label, link_params)
      end
    end
    filter.join(" | ")    
  end

  def n_lines(text, line_size)
    n_lines = 1
    if text.present?
      n_lines = text.split("\n").size
      if n_lines == 1 && text.length > line_size
        n_lines = text.length / line_size + 1
      end
    end
    n_lines
  end

  # We want to save and reload things as soon as they leave the field
  def watch_for_field_changes_js
    javascript_tag("
      $$('div.translation input, div.translation textarea').each(function(field) {
        // each time they move on, save if any changes were made
        field.observe('change', function(){
          save_translation_string(field);
        });
      });

      function save_translation_string(field) {
        indicators = field.up('.translation').down('.translation-indicators');
        saving_indicator = indicators.down('.saving');
        saved_indicator = indicators.down('.saved');
        failed_indicator = indicators.down('.failed');

        new Ajax.Request('/translate/translate', {
          method: 'post',
          parameters: { key: field.id, value: field.value, from: '#{@from_locale}', to: '#{@to_locale}' },
          onCreate: function(create) { saving_indicator.show(); saved_indicator.hide(); failed_indicator.hide();  },
          onComplete: function(complete) { saving_indicator.hide(); },
          onSuccess: function(success) { saved_indicator.show(); },
          onFailure: function(failure) { failed_indicator.show(); }
        });
      }
    ")
  end
end
