module Mongoid::TaggableWithContext::AggregationStrategy
  module ClassMethods
      # Collection name for storing results of tag count aggregation
      def aggregation_database_collection_for(context)
        (@aggregation_database_collection ||= {})[context] ||= Moped::Collection.new(self.collection.database, aggregation_collection_for(context))
      end

      def aggregation_collection_for(context)
        "#{collection_name}_#{context}_aggregation"
      end
      
      def tags_for(context, conditions={})
        aggregation_database_collection_for(context).find(get_criteria(conditions)).sort(_id: 1).to_a.map{ |t| t["_id"] }
      end
      
      # retrieve the list of tag with weight(count), this is useful for
      # creating tag clouds
      def tags_with_weight_for(context, conditions={})
        aggregation_database_collection_for(context).find(get_criteria(conditions)).sort(_id: 1).to_a.map{ |t| [t["_id"], t["value"].to_i] }
      end

      def get_criteria(conditions)
        criteria = {:value  => {"$gt"  => 0}}
        criteria.merge!(conditions.extract!(:criteria)[:criteria]) if conditions.has_key?(:criteria)
        criteria
      end
  end
end
