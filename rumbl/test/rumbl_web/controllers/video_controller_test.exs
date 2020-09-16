defmodule RumbleWeb.VideoControllerTest do
  use RumblWeb.ConnCase, async: true

  alias Rumbl.TestHelpers
  # alias 他のmoduleを呼び出すときに, 名前が長いから簡潔にして呼ぶ方法。

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, Routes.video_path(conn, :new)),
      get(conn, Routes.video_path(conn, :index)),
      get(conn, Routes.video_path(conn, :show, "123")),
      get(conn, Routes.video_path(conn, :edit, "123")),
      put(conn, Routes.video_path(conn, :update, "123", %{})),
      post(conn, Routes.video_path(conn, :create, %{})),
      delete(conn, Routes.video_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  # video_controller_test.change1.exs
  setup %{conn: conn, login_as: username} do
    user = TestHelpers.user_fixture(username: username)
           # ここをalias使用して呼び名を簡潔にして呼んでいる。
    conn = assign(conn, :current_user, user)

    {:ok, conn: conn, user: user}
  end

  test "lists all user's videos on index", %{conn: conn, user: user} do
    user_video = TestHelpers.video_fixture(user, title: "funny cats")
    other_video = TestHelpers.video_fixture(TestHelpers.user_fixture(username: "other"), title: "another video")

    conn = get conn, Routes.video_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing Videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end

  # video_controller_test.change2.exs
  describe "with a logged-in user" do

    setup %{conn: conn, login_as: username} do
      user = TestHelpers.user_fixture(username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "Teresa"

    test "lists all user's videos on index", %{conn: conn, user: user} do
      user_video = TestHelpers.video_fixture(user, title: "funny cates")
      other_video = TestHelpers.video_fixture(
        TestHelpers.user_fixture(username: "other"),
        title: "another video")

      conn = get conn, Routes.video_path(conn, :index)
      assert html_response(conn, 200) =~ ~r/Listing Videos/
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end

    # inside of login block
    alias Rumbl.Multimedia

    @create_attrs %{
      url: "http://youtu.bu",
      title: "vid",
      description: "a vid"}

    @invalid_attrs %{title: "invalid"}
    defp video_count, do: Enum.count(Multimedia.list_videos())

    @tags login_as: "Teresa"
    test "creates user video and redirects", %{conn: conn, user: user} do
      create_conn =
        post conn, Routes.video_path(conn, :create), video: @create_attrs

      assert %{id: id} = redirected_params(create_conn)
      assert redirected_to(create_conn) ==
        Routes.video_path(create_conn, :show, id)

      conn = get conn, Routes.video_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Video"

      assert Multimedia.get_video!(id).user_id == user.id
    end

    @tag login_as: "Teresa"
    test "doesn not create vid, renders errors when invalid", %{conn: conn} do
      count_before = video_count()
      conn =
        post conn, Routes.video_path(conn, :create), video: @invalid_attrs
      assert html_response(conn, 200) =~ "check the errors"
      assert video_count() == count_before
    end
  end

  # outside of login block
  # video_controller_test.change4.exs
  test "authorizes actions against access by other users", %{conn: conn} do
    owner = TestHelpers.user_fixture(username: "owner")
    video = TestHelpers.video_fixture(owner, @create_attrs)
    non_owner = TestHelpers.user_fixture(username: "sneaky")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      get(conn, Routes.video_path(conn, :show, video))
    end
    assert_error_sent :not_found, fn ->
      get(conn, Routes.video_path(conn, :edit, video))
    end
    assert_error_sent :not_found, fn ->
      put(conn, Routes.video_path(conn, :update, video, video: @create_attrs))
    end
    assert_error_sent :not_found, fn ->
      delete(conn, Routes.video_path(conn, :delete, video))
    end
  end
end