# == Schema Information
#
# Table name: apps
#
#  id                 :integer          not null, primary key
#  name               :string
#  desc               :text
#  backend            :string
#  cpu                :decimal(10, 2)
#  mem                :integer
#  disk               :integer
#  cmd                :string
#  args               :string
#  priority           :integer
#  runas              :string
#  constraints        :string
#  image              :string
#  network            :string
#  portmappings       :text
#  force_image        :boolean
#  privileged         :boolean
#  env                :text
#  volumes            :text
#  uris               :text
#  gateway            :text
#  health_check       :text
#  instances          :integer
#  service_id         :integer
#  current_version_id :integer
#  raw_config         :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  state              :string
#

class App < ApplicationRecord
  class Task; attr_accessor :id, :agentId, :ip, :created_at end
  include AASM
  PROTECTED_ATTRIBUTES = %w(id created_at updated_at raw_config service_id current_version_id backend)

  attr_accessor :labels
  attr_accessor :version_name

  serialize :env, Hash
  serialize :health_check, Hash
  serialize :portmappings, Array
  serialize :labels, Array
  serialize :volumes, Array
  serialize :uris, Array
  serialize :gateway, Hash

  belongs_to :service
  belongs_to :user
  belongs_to :group
  has_many :versions, dependent: :destroy
  has_many :audits, as: :entity, class_name: 'Audit'

  validates :name, presence: true
  validates :name, uniqueness: { scope: :service_id }

  before_validation(on: :create) do |app|
    app.instances ||= 0
  end

  before_save do
    self.raw_config = self.marathon_hash # temp solution
  end

  after_save(on: :create) do |app|
    app.versions.create name: self.version_name || self.name,
      raw_config: self.raw_config
  end


  before_destroy do |app|
    app.stop
  end

  aasm :column => :state do
    state :pending, :initial => true
    state :running
    state :done

    event :backend_run do
      transitions :from => [:pending, :done], :to => :running
    end

    event :backend_stop do
      transitions :from => [:pending, :running], :to => :done
    end
  end

  def state_or_backend_state
    self.state
  end

  def run
    begin
      Marathon::App.create marathon_hash
      self.backend_run!
    rescue Marathon::Error::MarathonError => e
      puts e
      puts e.details
    end

  end

  def stop
    begin
      Marathon::App.delete self.marathon_app_name
      self.backend_stop!
    rescue Marathon::Error::NotFoundError => e
      Rails.logger.debug e
    end

    if self.service.apps.running.present?
      begin
        Marathon::Group.delete self.service.name
      rescue Marathon::Error::NotFoundError => e
        Rails.logger.debug e
      end
    end

  end

  def suspend
    marathon_app.suspend!
  end

  def restart
    marathon_app.restart!
  end

  def change
    marathon_app.change!
  end

  def rollback(version)
    marathon_app.roll_back! version
  end

  def scale(ins = 1)
    marathon_app.scale! ins
  end


  def marathon_app_name
    self.service.name + "/" + self.name
  end

  def marathon_app
    begin
    Marathon::App.get self.marathon_app_name
    rescue Marathon::Error::NotFoundError => e
    end
  end

  def marathon_hash
    marathon_hash = {
      id: self.marathon_app_name,
      cpus: self.cpu.to_f,
      mem: self.mem,
      instances: self.instances,
      #executor: "",
      container: self.container_hash,
      env: self.env,
      labels: self.labels,
      #fetch: self.uris.map {|u| { "uri": u }},
      healthChecks: [ ]
    }

    if self.cmd.present?
      marathon_hash[:cmd] = self.cmd
    end

    marathon_hash
  end

  def container_hash
    {
      type: "DOCKER",
      docker: {
      image: self.image,
      network: self.network.upcase,
      privileged: self.privileged,
      #portMappings: self.portmappings,
    },
    volumes: self.volumes,
    }
  end
end
