class HubsController < ApplicationController
  include PublicationController
  include TheSortableTreeController::Rebuild
  include TheSortableTreeController::ExpandNode

  def show
    @hub = @post
    @hub.increment!(:show_count)
    @hubs = @hub.same_hubs.with_state(:published).nested_set

    @posts = @hub.publications.with_state(:published).nested_set.page(params[:page])
    render 'posts/index'
  end

  def set_post_and_user
    @post = Hub.where(title: params[:id]).with_states(:published, :draft).first
    @user = @post.user
  end

  def selector
    initialize_hubs_selector(params[:id], params[:klass], params[:pub_type])
    render layout: false, template: 'hubs/_selector'
  end

  def manage
    @posts = @user.send(controller_name)
              .roots
              .nested_set
              .with_pub_type(params[:pub_type])
              .with_states(:draft, :published)
              .page(params[:page]).per(params[:per_page])
  end
end