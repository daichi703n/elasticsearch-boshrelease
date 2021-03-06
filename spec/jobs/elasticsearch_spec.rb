require 'rspec'
require 'yaml'
require 'bosh/template/test'

describe 'elasticsearch job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job('elasticsearch') }

  describe 'elasticsearch.yml' do
    let(:template) { job.template('config/elasticsearch.yml') }
    let(:links) { [
        Bosh::Template::Test::Link.new(
          name: 'elasticsearch',
          instances: [Bosh::Template::Test::LinkInstance.new(address: '10.0.8.2')],
          properties: {
            'elasticsearch'=> {
              'cluster_name' => 'test'
            },
          }
        )
      ] }

    it 'configures defaults successfully' do
      config = YAML.safe_load(template.render({}, consumes: links))
      expect(config['node.name']).to eq('me/0')
      expect(config['node.master']).to eq(true)
      expect(config['node.data']).to eq(true)
      expect(config['node.ingest']).to eq(false)
      expect(config['cluster.name']).to eq('test')
      expect(config['discovery.zen.minimum_master_nodes']).to eq(1)
      expect(config['discovery.zen.ping.unicast.hosts']).to eq('10.0.8.2')
    end

    it 'makes elasticsearch.node.allow_data false' do
      config = YAML.safe_load(template.render({'elasticsearch' => {
        'node' => {
          'allow_data' => false
        }
      }}, consumes: links))
      expect(config['node.data']).to eq(false)
    end

    it 'configures elasticsearch.config_options' do
      config = YAML.safe_load(template.render({'elasticsearch' => {
        'config_options' => {
            'xpack' => {
              'monitoring' => {
                'enabled' => true
              },
              'security' => {
                'enabled' => true
              },
              'watcher' => {
                'enabled' => true
              }
          }
        }
      }}, consumes: links))
      expect(config['xpack']['monitoring']['enabled']).to eq(true)
      expect(config['xpack']['security']['enabled']).to eq(true)
      expect(config['xpack']['watcher']['enabled']).to eq(true)
    end
  end
end