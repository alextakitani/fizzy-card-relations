class Cards::ParentsController < ApplicationController
  include CardScoped

  def create
    parent = Current.user.accessible_cards.find_by!(number: params[:parent_number])

    if @card.update(parent: parent)
      respond_to do |format|
        format.turbo_stream
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.json { head :unprocessable_entity }
      end
    end
  end

  def destroy
    @card.update(parent: nil)

    respond_to do |format|
      format.turbo_stream
      format.json { head :no_content }
    end
  end
end
