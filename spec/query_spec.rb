require 'spec_helper'

describe Viadeo::Client do
  subject(:client) { Viadeo::Client.new('id', 'secret') }

  describe '#get' do

    it 'returns an object with status, headers and body' do
      obj = client.get('/test')
      expect(obj).to respond_to(:status)
      expect(obj).to respond_to(:headers)
      expect(obj).to respond_to(:body)
    end

    it 'raises exception if an error actually happens' do
      expect { client.get('/_raise_http_404') }.to raise_error(Viadeo::Errors::NotFoundError)
    end

    it 'raises ConflictError if 409 has occured' do
      expect { client.get('/_raise_http_409') }.to raise_error(Viadeo::Errors::ConflictError)
    end

    it 'sends queries' do
      obj = client.get('/test', param1: 'test')
      expect(obj.body.params.param1).to eq('test')
    end

  end

  describe '#post' do
    it 'sends queries and body' do
      obj = client.post('/test', {param1: 'test'}, {param2: 'body test'})
      expect(obj.body.params.param1).to eq('test')
      expect(obj.body.params.param2).to eq('body test')
    end

    it 'supports unicode' do
      obj = client.post('/test', {param1: 'test'}, {param2: [116, 233, 115, 116].pack("U*")})
      expect(obj.body.params.param2).to eq([116, 233, 115, 116].pack("U*"))
      expect(obj.body.content_type).to eq('application/x-www-form-urlencoded; charset=UTF-8')
    end
  end
end
