# We have to overload the Job function to manufacture a new "create_with_options" method
#
# This method will allow us to actually perform the correct type of queuing, IE whether
#     we want to do a unique enqueue or not
module ResqueDuplicateless
  module Ext
    module Resque
      module Job
        def create(queue, klass, *args)
          create_with_options :queue => queue, :class => klass, :args => args
        end
      
        def create_with_options(options = {})
          queue, klass, args = options[:queue], options[:class], options[:args]
          ::Resque.validate(klass, queue)

          if ::Resque.inline?
            # Instantiating a Resque::Job and calling perform on it so callbacks run
            # decode(encode(args)) to ensure that args are normalized in the same manner as a non-inline job
            new(:inline, {'class' => klass, 'args' => decode(encode(args))}).perform
          # FINALLY, a unique push!
          elsif options[:unique]
            ::Resque.unique_push(queue, :class => klass.to_s, :args => args)
          else
            ::Resque.push(queue, :class => klass.to_s, :args => args)
          end
        end
      end
    end
  end
end



# Now just kludge these methods in
module Resque
  class Job
    extend ResqueDuplicateless::Ext::Resque::Job
  end
end