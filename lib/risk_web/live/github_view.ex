defmodule RiskWeb.GithubView do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="">
      <div>
        One here
        <%= live_render(@socket, RiskWeb.GithubDeployView) %>
      </div>
      <div>
        One there
        <%= live_render(@socket, RiskWeb.GithubDeployView) %>
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

  def handle_event("github_random", value, socket) do
    # do the deploy process
    {:noreply, assign(socket, deploy_step: "random #{value}")}
  end

  # def handle_event("start_new_game", value, socket) do
  #   {:ok, pid} = Risk.GameSupervisor.start_game(value)

  # end
end
