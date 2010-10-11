module Devise
  module Orm
    module CouchPotato
      module Schema
        include Devise::Schema
        # Tell how to apply schema methods.
        def apply_devise_schema(name, type, options={})
          return unless Devise.apply_schema
          if [Date, DateTime].include?(type)
            property name, options.merge({ :type => Time })
          else
            property name, options
          end
        end

        def find_for_authentication(conditions)
          find(:conditions => conditions)
        end

        def find(*args)
          options = args.extract_options!
          raise "You can't search with more than one condition yet =(" if options[:conditions].keys.size > 1
          find_by_key_and_value(options[:conditions].keys.first, options[:conditions].values.first)
        end
        
        private
      
        def find_by_key_and_value(key, value)
          if key == :id
            ::CouchPotato.database.load(value.to_s)
          else
            ::CouchPotato.database.view(send("by_#{key}", {:key => value.to_s, :limit => 1})).first
          end
        end
      end
    end
  end
end