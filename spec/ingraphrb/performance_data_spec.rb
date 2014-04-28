# encoding: utf-8

require 'spec_helper'

describe IngraphRB::PerformanceData do
  let(:db) { IngraphRBTest.db }

  describe '#with_timespan' do
    it 'converts an array to a timestamp between the two elements'
    it 'takes a timespan object as-is'
    it 'otherwise creates a new timespan object'
  end

  describe 'initialization' do
    describe 'host normalization' do
      it 'takes an array of host objects as-is'
      it 'takes a single host object as-is'
      it 'takes an array of strings and finds all hosts matching those'
      it 'takes a single string and finds all hosts matching it'
    end

    it 'uses the smallest timeframe available by default'

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
