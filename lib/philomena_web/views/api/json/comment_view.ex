defmodule PhilomenaWeb.Api.Json.CommentView do
  use PhilomenaWeb, :view
  alias PhilomenaWeb.UserAttributionView
  alias Philomena.Textile.Renderer

  def render("index.json", %{comments: comments, total: total} = assigns) do
    %{
      comments: render_many(comments, PhilomenaWeb.Api.Json.CommentView, "comment.json", assigns),
      total: total
    }
  end

  def render("show.json", %{comment: comment} = assigns) do
    %{comment: render_one(comment, PhilomenaWeb.Api.Json.CommentView, "comment.json", assigns)}
  end

  def render("comment.json", %{comment: %{destroyed_content: true}}) do
    nil
  end

  def render("comment.json", %{comment: %{image: %{hidden_from_users: true}} = comment}) do
    %{
      id: comment.id,
      image_id: comment.image_id,
      user_id: nil,
      author: nil,
      body: nil,
      created_at: nil,
      updated_at: nil,
      edited_at: nil,
      edit_reason: nil
    }
  end

  def render("comment.json", %{comment: %{hidden_from_users: true} = comment}) do
    %{
      id: comment.id,
      image_id: comment.image_id,
      user_id: if(not comment.anonymous, do: comment.user_id),
      author: UserAttributionView.name(comment),
      avatar: UserAttributionView.avatar_url(comment),
      body: nil,
      created_at: comment.created_at,
      updated_at: comment.updated_at,
      edited_at: nil,
      edit_reason: nil
    }
  end

  def render("comment.json", %{conn: conn, comment: comment}) do
    %{
      id: comment.id,
      image_id: comment.image_id,
      user_id: if(not comment.anonymous, do: comment.user_id),
      author: UserAttributionView.name(comment),
      avatar: UserAttributionView.avatar_url(comment),
      body: parse_content(conn, comment.body),
      created_at: comment.created_at,
      updated_at: comment.updated_at,
      edited_at: comment.edited_at,
      edit_reason: comment.edit_reason
    }
  end

  defp parse_content(conn, content) do
    case conn.params do
      %{"html" => "true"} ->
        opts = %{image_transform: &Camo.Image.image_url/1}
        Renderer.render_one(%{body: content}, conn)

      _ ->
        content
    end
  end
end
