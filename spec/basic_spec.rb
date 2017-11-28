require "helper/spec_init"

describe ResqueDuplicateless do
  describe "Basic" do
    QUEUES = ["ruj:rspec:queue_1", "ruj:rspec:queue_2"]
    
    before :all do 
      QUEUES.each {|queue_name| Resque.redis.del "queue:#{queue_name}"}
    end
    
    after :each do 
      QUEUES.each {|queue_name| Resque.redis.del "queue:#{queue_name}"}
    end
  
    it "can add a job to the queue" do
      Resque.enqueue_uniquely DummyWorker
      expect(Resque.size(QUEUES[0])).to eql(1)
    end
  
    it "cannot add a second job of the same parameters to the same queue" do
      Resque.enqueue_uniquely DummyWorker
      expect(Resque.size(QUEUES[0])).to eql(1)
      Resque.enqueue_uniquely DummyWorker
      expect(Resque.size(QUEUES[0])).to eql(1)
    end
  
    it "can enqueue two of the same job, to the same queue, if the params are different" do
      Resque.enqueue_uniquely DummyWorker, 0
      expect(Resque.size(QUEUES[0])).to eql(1)
      Resque.enqueue_uniquely DummyWorker, 1
      expect(Resque.size(QUEUES[0])).to eql(2)
    end
    
    it "can enqueue the same job with the same params to two different queues" do
      Resque.enqueue_uniquely DummyWorker
      Resque.enqueue_uniquely_to :queue_2, DummyWorker
      expect(Resque.size(QUEUES[0])).to eql(1)
      expect(Resque.size(QUEUES[1])).to eql(1)
    end
    
    it "doesn't matter if we enqueued normally before, unique is unique" do
      Resque.enqueue DummyWorker
      expect(Resque.size(QUEUES[0])).to eql(1)
      Resque.enqueue_uniquely DummyWorker
      expect(Resque.size(QUEUES[0])).to eql(1)
    end
    
    it "will not remove multiples added through the normal enqueue method" do
      Resque.enqueue DummyWorker
      Resque.enqueue DummyWorker
      expect(Resque.size(QUEUES[0])).to eql(2)
      Resque.enqueue_uniquely DummyWorker
      expect(Resque.size(QUEUES[0])).to eql(2)
    end
    
    it "will maintain the job order when trying to uniquely add" do
      Resque.enqueue DummyWorker, 0
      Resque.enqueue DummyWorker, 1
      Resque.enqueue DummyWorker, 2
      Resque.enqueue_uniquely DummyWorker, 3
      Resque.enqueue_uniquely DummyWorker, 3
      Resque.enqueue_uniquely DummyWorker, 1
      Resque.enqueue_uniquely DummyWorker, 2
      Resque.enqueue_uniquely DummyWorker, 4
      expect(Resque.size(QUEUES[0])).to eql(5)
      args = Resque.data_store.everything_in_queue(QUEUES[0]).map{|s| JSON.parse(s)["args"].first}
      (0..4).each {|i| expect(args[i]).to eq(i)}
    end
  end
end