module Mongoid::TaggableWithContext::AggregationStrategy
  module ClassMethods
      # Collection name for storing results of tag count aggregation
      def aggregation_collection_for(context)
        "#{collection_name}_#{context}_aggregation"
      end
      
      def tags_for(context, conditions={})
        criteria = get_criteria(conditions)
        conditions = {:sort => '_id'}.merge(conditions)
        db.collection(aggregation_collection_for(context)).find(criteria, conditions).to_a.map{ |t| t["_id"] }
      end

      # retrieve the list of tag with weight(count), this is useful for
      # creating tag clouds
      def tags_with_weight_for(context, conditions={})
        conditions = {:sort => '_id'}.merge(conditions)
        db.collection(aggregation_collection_for(context)).find(get_criteria(conditions), conditions).to_a.map{ |t| [t["_id"], t["value"]] }
      end

      def get_criteria(conditions)
        criteria = {:value  => {"$gt"  => 0}}
        criteria.merge!(conditions.extract!(:criteria)[:criteria]) if conditions.has_key?(:criteria)
        criteria
      end
  end
end
