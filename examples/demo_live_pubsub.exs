Mix.install([
  {:phoenix_playground, "~> 0.1.6"}
])

defmodule TimelineLive do
  use Phoenix.LiveView

  @topic "timeline"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PhoenixPlayground.PubSub, @topic)
    end

    socket =
      socket
      |> assign(temporary_assigns: [form: nil])
      |> stream(:posts, [])
      |> assign(:form, to_form(%{"content" => ""}))

    {:ok, socket}
  end

  def handle_event("create_post", %{"content" => content}, socket) do
    post = %{
      id: System.unique_integer([:positive]),
      content: content,
      inserted_at: DateTime.utc_now()
    }

    Phoenix.PubSub.broadcast(PhoenixPlayground.PubSub, @topic, {:new_post, post})

    {:noreply,
     socket
     |> assign(:form, to_form(%{"content" => ""}))}
  end

  def handle_event("delete_post", %{"dom_id" => dom_id}, socket) do
    Phoenix.PubSub.broadcast(PhoenixPlayground.PubSub, @topic, {:delete_post, dom_id})

    {:noreply, socket}
  end

  def handle_info({:new_post, post}, socket) do
    {:noreply, stream_insert(socket, :posts, post, at: 0)}
  end

  def handle_info({:delete_post, dom_id}, socket) do
    {:noreply, stream_delete_by_dom_id(socket, :posts, dom_id)}
  end

  def render(assigns) do
    ~H"""
    <div class="timeline">
      <h1>Timeline</h1>

      <.form for={@form} phx-submit="create_post" id="post-form">
        <textarea name="content" placeholder="What's on your mind?" id="content" phx-hook="CmdEnterSubmit"><%= @form.params["content"] %></textarea>
        <button type="submit">Post</button>
      </.form>

      <div class="posts" phx-update="stream" id="posts">
        <div :for={{dom_id, post} <- @streams.posts} id={dom_id} class="post">
          <div class="post-content">
            <p><%= post.content %></p>
            <small>{Calendar.strftime(post.inserted_at, "%d.%m.%Y %H:%M:%S")}</small>
          </div>
          <button phx-click="delete_post" phx-value-dom_id={dom_id} class="delete-btn">Delete</button>
        </div>
      </div>
    </div>

    <script>
      window.hooks.CmdEnterSubmit = {
        mounted() {
        this.el.addEventListener("keydown", (e) => {
          if (e.metaKey && e.key === 'Enter') {
            this.el.form.dispatchEvent(
              new Event('submit', {bubbles: true, cancelable: true}));
          }
        })
        }
      }
    </script>

    <style>
      * {
        box-sizing: border-box;
      }

      .timeline {
        max-width: 800px;
        margin: 0 auto;
        padding: 20px;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      }

      h1 {
        color: #2c3e50;
        font-size: 2.5em;
        margin-bottom: 1em;
        text-align: center;
      }

      .post {
        border: 1px solid #e1e8ed;
        border-radius: 12px;
        padding: 16px;
        margin: 16px 0;
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        background: white;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        transition: all 0.2s ease;
      }

      .post:hover {
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        transform: translateY(-2px);
      }

      .post-content {
        flex: 1;
        margin-right: 16px;
      }

      .post-content p {
        color: #2c3e50;
        font-size: 1.1em;
        line-height: 1.5;
        margin: 0 0 8px 0;
        word-wrap: break-word;
        overflow-wrap: break-word;
      }

      .post-content small {
        color: #8795a1;
        font-size: 0.9em;
        display: block;
        word-wrap: break-word;
        overflow-wrap: break-word;
      }

      form {
        margin: 20px 0;
        background: white;
        padding: 20px;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        width: 100%;
      }

      textarea {
        width: 100%;
        min-height: 3ch;
        margin-bottom: 16px;
        padding: 12px;
        border: 2px solid #e1e8ed;
        border-radius: 8px;
        font-size: 1em;
        resize: vertical;
        transition: border-color 0.2s ease;
      }

      textarea:focus {
        outline: none;
        border-color: #4a9eff;
      }

      button {
        padding: 10px 20px;
        background: #4a9eff;
        color: white;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        font-size: 1em;
        font-weight: 500;
        transition: all 0.2s ease;
      }

      button:hover {
        background: #357abd;
        transform: translateY(-1px);
      }

      .delete-btn {
        background: #ff4a4a;
        margin-left: 10px;
        padding: 8px 16px;
        font-size: 0.9em;
        opacity: 0.8;
      }

      .delete-btn:hover {
        background: #bd3535;
        opacity: 1;
      }

      body {
        background: #f8fafc;
        margin: 0;
        padding: 20px;
      }
    </style>
    """
  end
end

PhoenixPlayground.start(live: TimelineLive)
