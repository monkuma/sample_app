module SessionsHelper
  # 渡されたユーザーでログイン
  def log_in(user)
    session[:user_id] = user.id
    # セッションリプレイ攻撃を防ぐために、セッションIDを再生成
    session[:session_token] = user.session_token
  end

  # 永続的セッションのためユーザーを記憶
  def remember(user)
    user.remember # ユーザーのremember_digestを更新
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 現在ログイン中のユーザーを返す (いる場合)
  def current_user
    return unless session[:user_id]

    @current_user ||= User.find_by(id: session[:user_id])
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄
  def forget(user)
    user.forget # ユーザーのremember_digestをnilにする
    cookies.delete(:user_id) # cookieのuser_idを削除
    cookies.delete(:remember_token) # cookieのremember_tokenを削除
  end

  # 現在のユーザーをログアウト
  def log_out
    forget(current_user) # 永続的セッションを破棄
    reset_session
    @current_user = nil # セッションをリセット
  end

  # 記憶トークンのcookieに対応するユーザーを返す
  def current_user
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # 渡されたユーザーがログイン中のユーザーであればtrueを返す
  def current_user?(user)
    user && user == current_user
  end

  # アクセスしようとしたURL保存
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
