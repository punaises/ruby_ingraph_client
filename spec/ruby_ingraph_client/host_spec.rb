# encoding: utf-8

require 'spec_helper'

describe RubyIngraphClient::Host do
  let(:db) { RubyIngraphClientTest.db }

  describe '.sanitize_pattern' do
    it 'replaces asterisks with percent signs' do
      expect(RubyIngraphClient::Host.sanitize_pattern('asdf*foo*'))
        .to eq('asdf%foo%')
    end
  end

  describe '.matching' do
    subject { RubyIngraphClient::Host.matching(db, pattern) }

    context 'when using a pattern' do
      let(:pattern) { 'server%' }
      its(:size) { eq(3) }

      it 'finds the right servers' do
        names = subject.map { |h| h.name }
        expect(names[0]).to eq('server1')
        expect(names[1]).to eq('server2')
        expect(names[2]).to eq('server3')
      end

      it 'finds the right server ids' do
        ids = subject.map { |h| h.id }
        expect(ids[0]).to eq(1)
        expect(ids[1]).to eq(2)
        expect(ids[2]).to eq(3)
      end
    end

    context 'when the pattern does not match any hosts' do
      let(:pattern) { 'uhoh' }
      its(:size) { should eq(0) }
    end
  end
end
