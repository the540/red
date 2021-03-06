class RepositoriesController < ApplicationController
  before_action :set_namespace, :set_repository, :set_breadcrumb

  def show
    @repo_tags  = @repository.repo_tags.order('id desc')
  end

  private

  def set_namespace
    @namespace = Namespace.find(params[:namespace_id])
    @namespaces = Namespace.all
  end

  def set_repository
    @repository = @namespace.repositories.find params[:id]
  end

  def set_breadcrumb
    @breadcrumb_list = [OpenStruct.new(name_zh_cn: "全部镜像库", name_en: "Namespaces", path: namespaces_path)]

    if @namespace
      @breadcrumb_list.push OpenStruct.new(name_zh_cn: @namespace.name, name_en: @namespace.name, path: namespace_path(@namespace))
    end

    if @repository
      @breadcrumb_list.push OpenStruct.new(name_zh_cn: @repository.name, name_en: @repository.name, path: namespace_repository_path(@namespace, @repository))
    end
  end
end
