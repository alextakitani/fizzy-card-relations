class Cards::DependenciesController < ApplicationController
  include CardScoped

  def create
    blocker = Current.user.accessible_cards.find_by!(number: params[:blocker_number])
    dependency = @card.card_dependencies.create(blocker: blocker)

    if dependency.persisted?
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
    blocker = Current.user.accessible_cards.find(params[:id])
    @card.card_dependencies.destroy_by(blocker: blocker)

    respond_to do |format|
      format.turbo_stream
      format.json { head :no_content }
    end
  end
end
