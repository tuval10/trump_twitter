require 'rails_helper'

describe ApplicationJob, type: :job do
  let(:job) {described_class.new}

  describe 'default_last_update' do
    it 'should get default date' do
      expected = Time.parse("2018-01-1 00:00:00 UTC")
      expect(job.send(:default_last_update)).to eq(expected)
    end
  end
end