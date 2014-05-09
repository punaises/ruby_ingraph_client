# encoding: utf-8

require 'spec_helper'

describe IngraphRB::PerformanceData do
  let(:db) { IngraphRBTest.db }

  describe '#with_timespan' do
    let(:perfdata) do
      IngraphRB::PerformanceData.new(db, '', '')
    end

    it 'converts an array to a timestamp between the two elements' do
      perfdata.with_timespan(['2 days ago', '1 day ago'])
      expect(perfdata.timespan.start_time)
        .to be_within(1).of(Time.now - 2 * 24 * 60 * 60)
      expect(perfdata.timespan.end_time)
        .to be_within(1).of(Time.now - 24 * 60 * 60)
    end

    it 'takes a timespan object as-is' do
      timespan = Timespan.new(1.day)
      expect(perfdata.with_timespan(timespan).timespan)
        .to eq(timespan)
    end

    it 'otherwise creates a new timespan object' do
      args = { start: 1.day.ago, duration: 2.days }
      timespan = Timespan.new(args)
      expect(perfdata.with_timespan(args).timespan)
        .to eq(timespan)
    end
  end

  describe 'initialization' do
    describe 'host normalization' do
      let(:perfdata) { IngraphRB::PerformanceData.new(db, @hosts, '') }

      it 'takes an array of host objects as-is' do
        @hosts = [IngraphRB::Host.new(id: 1, name: 'test1')]
        expect(perfdata.hosts).to eq(@hosts)
      end

      it 'takes a single host object and returns it as an array' do
        @hosts = IngraphRB::Host.new(id: 1, name: 'test1')
        expect(perfdata.hosts).to eq([@hosts])
      end

      it 'takes an array of strings and finds all hosts matching those' do
        @hosts = ['server1', 'server2']
        expected = @hosts.map { |h| IngraphRB::Host.find(db, h) }
        expect(perfdata.hosts).to match_array(expected)
      end

      it 'takes a single string and finds all hosts matching it' do
        @hosts = 'server%'
        expected = %w[server1 server2 server3].map do |h|
          IngraphRB::Host.find(db, h)
        end
        expect(perfdata.hosts).to match_array(expected)
      end
    end

    it 'uses the smallest timeframe available by default' do
      perfdata = IngraphRB::PerformanceData.new(db, '', '')
      expect(perfdata.timeframe.interval).to eq(300)
    end

    context 'finding plot ids' do
      context 'when the plot exists'
      context 'when no matching plot exists'
    end
  end

  describe '#fetch' do
    it 'returns an array of hashes, one per data point'
    describe 'result row' do
      it 'has a plot_id field'
      it 'has a host_name field'
      it 'has a timestamp field'
      it 'has a time (offset) field'
      it 'has a value field'
    end
  end
end
