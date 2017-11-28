# We need to kludge in the method to uniquely add an item into a queue
#
# This is a little bit complicated because of how Resque is built. It uses an internal object known
# as the QueueAccess object to actually interact with the queues. Because of this, we want to extend
# those objects to follow their practices
module ResqueUniqueJob
  module Ext
    module Resque
      module DataStore
        
        def uniquely_push_to_queue(queue, item)
          @queue_access.uniquely_push_to_queue queue, item
        end
        
        # This is the extension for the QueueAccess Object
        module QueueAccess
        
          # This function calls our LUA script for evaluation.
          def uniquely_push_to_queue(queue, item)
            out = nil
            # Ensure the script is loaded
            @redis.redis.script(:load, uniquely_push_to_queue_script) unless @redis.redis.script(:exists, uniquely_push_to_queue_script_sha)
            
            # Now pipeline the watch and addition calls
            @redis.pipelined do
              watch_queue queue
              out = @redis.evalsha uniquely_push_to_queue_script_sha, [redis_key_for_queue_also(queue)], [item]
            end
            out.value
          end 
          
          protected
          
          # TODO: Resque queue names should really be protected, not private
          def redis_key_for_queue_also(queue)
            "queue:#{queue}"
          end
          
          # Create the SHA once and save it to avoid doing it repeatedly for no reason
          def uniquely_push_to_queue_script_sha
            @uniquely_push_to_queue_script_sha = Digest::SHA1.hexdigest uniquely_push_to_queue_script unless @uniquely_push_to_queue_script_sha
            @uniquely_push_to_queue_script_sha
          end
          
          # The LUA script to uniquely add to queue
          #
          # It *always* runs O(n)
          #
          # It has two parts
          # 1. Use RPOPLPUSH to cycle through the entire array. 
          #    It must complete the cycle, even if it finds something, so that the list's order is maintained
          # 1A. If the list is empty, then we don't need to do this. Non-existant lists are considered empty
          #
          # 2. If it does not find the item, then add it to the tail of the list
          def uniquely_push_to_queue_script
<<-FOO
local list_size = redis.call('LLEN',KEYS[1])
local response = 0
if list_size > 0 then
  for i=1,list_size
  do
    redis.call('RPOPLPUSH',KEYS[1],KEYS[1])
    if ARGV[1] == redis.call('LINDEX',KEYS[1],0) then response = 1 end
  end
end
if response == 0 then redis.call('RPUSH',KEYS[1],ARGV[1]) end
return 1
FOO
          end
          
        end
      end
    end
  end
end

# Now just kludge these methods in
module Resque
  class DataStore
    include ResqueUniqueJob::Ext::Resque::DataStore
    class QueueAccess
      include ResqueUniqueJob::Ext::Resque::DataStore::QueueAccess
    end
  end
end