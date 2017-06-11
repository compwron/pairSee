describe PairSee::DateCombo do
  let(:date) { '0-1-1' }
  let(:devs) { [] }
  subject { PairSee::DateCombo.new(date, devs) }

  describe 'nil date' do
    let(:date) { nil }
    it 'returns nothingness' do
      expect(subject.to_s).to eq ': not yet'
    end
  end

  describe 'greater than' do
    let(:early_dc) { PairSee::DateCombo.new('2016-1-1', devs) }
    let(:late_dc) { PairSee::DateCombo.new('2016-1-2', devs) }
    let(:dateless_dc) { PairSee::DateCombo.new(nil, devs) }
    let(:other_dateless_dc) { PairSee::DateCombo.new(nil, devs) }

    it 'is greater than a DateCombo with an earlier date' do
      expect([late_dc, early_dc].sort).to eq [early_dc, late_dc]
      expect([early_dc, late_dc].sort).to eq [early_dc, late_dc]
    end

    it 'is greater than nothingness' do
      expect([early_dc, dateless_dc].sort).to eq [dateless_dc, early_dc]
      expect([dateless_dc, early_dc].sort).to eq [dateless_dc, early_dc]
    end

    it 'has no order with two dateless' do
      expect([dateless_dc, other_dateless_dc].sort).to eq [dateless_dc, other_dateless_dc]
      expect([other_dateless_dc, dateless_dc].sort).to eq [other_dateless_dc, dateless_dc]
    end
  end

  describe 'empty devs' do
    it 'returns nothingness' do
      expect(subject.to_s).to eq ': 0-1-1'
    end
  end

  describe 'with one dev' do
    let(:devs) { ['dev1'] }
    it 'returns nothingness' do
      expect(subject.to_s).to eq 'dev1: 0-1-1'
    end
  end

  describe 'with two devs' do
    let(:devs) { ['dev1', 'dev2'] }
    it 'returns both devs' do
      expect(subject.to_s).to eq 'dev1, dev2: 0-1-1'
    end
  end

  describe 'with three devs' do
    let(:devs) { ['dev1', 'dev2'] }
    it 'returns only two devs since this is a combo' do
      expect(subject.to_s).to eq 'dev1, dev2: 0-1-1'
    end
  end
end
