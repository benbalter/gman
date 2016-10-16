RSpec.describe 'Gman domains' do
  let(:resolve_domains?) { ENV['GMAN_RESOLVE_DOMAINS'] == 'true' }
  let(:importer) { Gman::Importer.new({}) }
  let(:options) { { skip_dupe: true, skip_resolve: !resolve_domains? } }

  Gman.list.to_h.each do |group, domains|
    next if ['non-us gov', 'non-us mil', 'US Federal'].include?(group)

    context "the #{group} group" do
      Parallel.each(domains, in_threads: 4) do |domain|
        context "the #{domain} domain" do
          let(:valid_domain?) { importer.valid_domain?(domain, options) }

          it 'is a valid domain' do
            expect(valid_domain?).to eql(true)
          end
        end
      end
    end
  end
end
