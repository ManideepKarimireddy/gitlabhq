# frozen_string_literal: true

module DeploymentPlatform
  # EE would override this and utilize environment argument
  # rubocop:disable Gitlab/ModuleWithInstanceVariables
  def deployment_platform(environment: nil)
    @deployment_platform ||= {}

    @deployment_platform[environment] ||= find_deployment_platform(environment)
  end

  private

  def find_deployment_platform(environment)
    find_cluster_platform_kubernetes(environment: environment) ||
      find_group_cluster_platform_kubernetes(environment: environment) ||
      find_instance_cluster_platform_kubernetes(environment: environment)
  end

  # EE would override this and utilize environment argument
  def find_cluster_platform_kubernetes(environment: nil)
    clusters.enabled.default_environment
      .last&.platform_kubernetes
  end

  # EE would override this and utilize environment argument
  def find_group_cluster_platform_kubernetes(environment: nil)
    Clusters::Cluster.enabled.default_environment.ancestor_clusters_for_clusterable(self)
      .first&.platform_kubernetes
  end

  # EE would override this and utilize environment argument
  def find_instance_cluster_platform_kubernetes(environment: nil)
    Clusters::Instance.new.clusters.enabled.default_environment
      .first&.platform_kubernetes
  end
end
