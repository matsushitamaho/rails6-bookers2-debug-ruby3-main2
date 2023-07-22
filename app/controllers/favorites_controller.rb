class FavoritesController < ApplicationController
  def create
    book = Book.find(params[:book_id])
    favorite = current_user.favorites.new(book_id: book.id)
    favorite.save
    redirect_to request.referer
  end
  
  def destroy
    book = Book.find(params[:book_id])
    favorite = current_user.favorites.find_by(book_id: book.id)
    if favorite
      favorite.destroy
    else
      flash[:alert] = "お気に入りが見つかりませんでした。"
    end
    redirect_to request.referer
  end
end
