defmodule PhilomenaWeb.Api.Json.Forum.Topic.PostView do
  use PhilomenaWeb, :view
  alias PhilomenaWeb.UserAttributionView
  alias Philomena.Textile.Renderer

  def render("index.json", %{posts: posts, total: total} = assigns) do
    %{
      posts: render_many(posts, PhilomenaWeb.Api.Json.Forum.Topic.PostView, "post.json", assigns),
      total: total
    }
  end

  def render("show.json", %{post: post} = assigns) do
    %{post: render_one(post, PhilomenaWeb.Api.Json.Forum.Topic.PostView, "post.json", assigns)}
  end

  def render("post.json", %{post: %{topic: %{hidden_from_users: true}} = post}) do
    %{
      id: post.id,
      user_id: nil,
      author: nil,
      body: nil,
      created_at: nil,
      updated_at: nil,
      edited_at: nil,
      edit_reason: nil
    }
  end

  def render("post.json", %{post: %{hidden_from_users: true} = post}) do
    %{
      id: post.id,
      user_id: if(not post.anonymous, do: post.user_id),
      author: UserAttributionView.name(post),
      avatar: UserAttributionView.avatar_url(post),
      body: nil,
      created_at: post.created_at,
      updated_at: post.updated_at,
      edited_at: nil,
      edit_reason: nil
    }
  end

  def render("post.json", %{conn: conn, post: post}) do
    opts = %{image_transform: &Camo.Image.image_url/1}

    %{
      id: post.id,
      user_id: if(not post.anonymous, do: post.user_id),
      author: UserAttributionView.name(post),
      avatar: UserAttributionView.avatar_url(post),
      body: post.body,
      body_html: Renderer.render_one(post, opts),
      created_at: post.created_at,
      updated_at: post.updated_at,
      edited_at: post.edited_at,
      edit_reason: post.edit_reason
    }
  end
end
