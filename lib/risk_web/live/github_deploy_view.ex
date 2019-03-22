defmodule RiskWeb.GithubDeployView do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="">
      <div>
        <div>
          <button phx-click="github_deploy">Deploy to GitHub</button>
        </div>
        Status: <%= @deploy_step %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, deploy_step: "Ready!")}
  end

  def handle_event("github_deploy", _value, socket) do
    # do the deploy process
    {:noreply, assign(socket, deploy_step: "Starting deploy...")}
  end
end
