module Mongoid::TaggableWithContext::AggregationStrategy
  module MapReduce
    extend ActiveSupport::Concern
    included do
      set_callback :save,     :after, :map_reduce_all_contexts!, :if => :tags_changed?
      set_callback :destroy,  :after, :map_reduce_all_contexts!
      delegate :aggregation_collection_for, :to => "self.class"
    end
    
    module ClassMethods
      include Mongoid::TaggableWithContext::AggregationStrategy::ClassMethods
    end
    
    protected

    def changed_tag_arrays
      tag_array_attributes & changes.keys.map(&:to_sym)
    end
    
    def tags_changed?
      !changed_tag_arrays.empty?
    end
    
    def map_reduce_all_contexts!
      tag_contexts.each do |context|
        map_reduce_context!(context)
      end
    end
    
    def map_reduce_context!(context)
      field = tag_options_for(context)[:array_field]

      map = <<-END
        function() {
          if (!this.#{field})return;
          for (index in this.#{field})
            emit(this.#{field}[index], 1);
        }
      END

      reduce = <<-END
        function(key, values) {
          var count = 0;
          for (index in values) count += values[index];
          return count;
        }
      END

      self.class.map_reduce(map, reduce).out(replace: aggregation_collection_for(context)).time
    end
  end
end
