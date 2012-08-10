##
# Pillboxr monkeypatches the ActiveResource::Base.instantiate_collection method
# to remove the disclaimer included in all XML returned from the Pillbox API Service
module ActiveResource
  class Base           
     def self.instantiate_collection(collection, prefix_options = {}) # :nodoc:
      if collection.is_a?(Hash) && collection.size == 1
        value = collection.values.first
        if value.is_a?(Array)
          value.collect! { |record| instantiate_record(record, prefix_options) }
        else
          [ instantiate_record(value, prefix_options) ]
        end
      else
        # strip extra layer off the front end (a disclaimer)
        (d,disclaimer), (p,collection), (r,@@record_count) = collection.sort

        puts "\nMatched #{@@record_count} records...\n"
        @@record_count = Integer(@@record_count)

        # ensure array
        collection = collection.is_a?(Array) ? collection : Array[collection]
        
        collection.collect! { |record| instantiate_record(record, prefix_options) }
      end
    end
  end
end