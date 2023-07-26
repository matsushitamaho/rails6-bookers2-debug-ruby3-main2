class MessagesController < ApplicationController
  before_action :reject_non_related, only: [:show]
  def show
    @user = User.find(params[:id])                             # メッセージ相手のユーザーを見つける
    rooms = current_user.entries.pluck(:room_id)               # 現在のユーザーのエントリー（参加しているチャットルーム）のIDを取得する
    entries = Entry.find_by(user_id: @user.id, room_id: rooms) # メッセージ相手のユーザーと現在のユーザーの間で共有されているエントリーを見つける

    # 共有されているエントリーが存在しない場合
    unless entries.nil?
      @room = entries.room                                     # 関連するルームを取得
    else
      @room = Room.new                                         # 新しいルームを作成してエントリーを作成
      @room.save
      Entry.create(user_id: current_user.id, room_id: @room.id)
      Entry.create(user_id: @user.id, room_id: @room.id)
    end
    @messages = @room.messages                                 # ルーム内のメッセージを取得
    @message = Message.new(room_id: @room.id)                  # 新しいメッセージ用のインスタンスを作成
  end
  
  # メッセージの作成アクション
  def create
    @message = current_user.messages.new(message_params)       # 現在のユーザーに関連付けて新しいメッセージを作成
    render :validater unless @message.save                     # メッセージの保存が成功しなかった場合は、バリデーションエラーを表示する
  end

  private
  def message_params
    params.require(:message).permit(:message, :room_id)
  end

  def reject_non_related
    user = User.find(params[:id])
    # 現在のユーザーとメッセージ相手のユーザーがお互いにフォローしていない場合、books_pathにリダイレクトする
    unless current_user.following?(user) && user.following?(current_user)
      redirect_to books_path
    end
  end
end
