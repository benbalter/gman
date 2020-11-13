# frozen_string_literal: true

RSpec.describe Gman do
  context 'valid domains' do
    ['foo.gov', 'http://foo.mil', 'foo@bar.gc.ca', 'foo.gov.au',
     'https://www.foo.gouv.fr', 'foo@ci.champaign.il.us',
     'foo.bar.baz.gov.au', 'foo@bar.gov.uk', 'foo.gov',
     'foo.fed.us', 'foo.state.il.us', 'state.il.us',
     'foo@af.mil', 'foo.gov.in'].each do |domain|
       subject { described_class.new(domain) }

       it "knows #{domain.inspect} is valid government domain" do
         expect(described_class.valid?(domain)).to be(true)
         expect(subject.valid?).to be(true)
       end
     end
  end

  context 'invalid domains' do
    ['foo.bar.com', 'bar@foo.biz', 'http://www.foo.biz',
     'foo.uk', 'gov', 'foo@k12.champaign.il.us', 'foo@kii.gov.by',
     'foo', '', nil, ' ', 'foo.city.il.us', 'foo.ci.il.us',
     'foo.zx.us', 'foo@mail.gov.ua', 'foo@gwu.edu'].each do |domain|
      subject { described_class.new(domain) }

      it "knows #{domain.inspect} is not a valid government domain" do
        expect(described_class.valid?(domain)).to be(false)
        expect(subject.valid?).to be(false)
      end
    end
  end

  context 'localities' do
    subject { described_class.new(domain) }

    context 'when given github.gov' do
      let(:domain) { 'github.gov' }

      it "knows it's not a locality" do
        expect(subject.locality?).to be(false)
      end
    end

    context 'when given foo.state.il.us' do
      let(:domain) { 'foo.state.il.us' }

      it "knows it's a locality" do
        expect(subject.locality?).to be(true)
      end
    end
  end

  context 'class methods' do
    it 'returns the domain list' do
      expect(described_class.list).to be_a(Gman::DomainList)
    end

    it 'returns the academic list' do
      expect(described_class.academic_list).to be_a(Gman::DomainList)
    end

    it 'returns the config path' do
      expect(Dir.exist?(described_class.config_path)).to be(true)
    end

    it 'returns the list path' do
      expect(File.exist?(described_class.list_path)).to be(true)
    end

    it 'returns the academic list path' do
      expect(File.exist?(described_class.academic_list_path)).to be(true)
    end
  end
end
