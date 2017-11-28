# We are going to make a extension that kludges a couple of methods into the Resque main object
module ResqueUniqueJob
  module Ext
    module Resque
      def unique_push(queue, item)
        data_store.uniquely_push_to_queue queue, encode(item)
      end 
      
      # This method is basically a copy of "enqueue", but it will make sure
      # that the enqueue method happens uniquely using this plugin
      def enqueue_uniquely(klass, *args)
        enqueue_uniquely_to queue_from_class(klass), klass, *args
      end
      
      # We need to rewrite enqueue_to in order to use enqueue_with-options
      def enqueue_to(queue, klass, *args)
        enqueue_with_options :queue => queue, :class => klass, :args => args
      end
      
      # This is basically a copy of enqueue_to, but will make sure that the enqueue 
      # happens uniquely using this plugin
      def enqueue_uniquely_to(queue, klass, *args)
        enqueue_with_options :queue => queue, :class => klass, :args => args, :unique => true
      end
      
      # We are going to create a new "base" job creation method. This will allow us to send options 
      # into the enqueue function and, eventually, the Job.create function
      def enqueue_with_options(options = {})
        surround_enqueue(options) do
          ::Resque::Job.create_with_options(options)
        end
      end
      
      protected
      
      # We are goung to do a surrounding enqueue function so that the hooks are called in a separate function,
      # should we need to make changes to them separately for some reason. We could have done this in two functions,
      # but because the before and after hooks should have the same basic options and form, we do it in one
      #
      # The code here is basically ripped straight from Resque (commit 0420094)
      def surround_enqueue(options)
        queue, klass, args = options[:queue], options[:class], options[:args]
        
        # Perform before_enqueue hooks. Don't perform enqueue if any hook returns false
        before_hooks = ::Resque::Plugin.before_enqueue_hooks(klass).collect do |hook|
          klass.send(hook, *args)
        end
        return nil if before_hooks.any? { |result| result == false }
        
        yield

        ::Resque::Plugin.after_enqueue_hooks(klass).each do |hook|
          klass.send(hook, *args)
        end

        return true
      end
    end
  end
end

# Perform the actual kludge
module Resque
  extend ResqueUniqueJob::Ext::Resque
end