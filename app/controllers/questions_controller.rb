class QuestionsController < ApplicationController

  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy

  def index
   #before making optimizations
=begin
    @q = Question.ransack(params[:q])
	 @questions = @q.result.paginate(page: params[:page])
   #after making optimizations
=end
    if stale?(Question.all)
      @q = Question.includes(:user).ransack(params[:q])
	   @questions = @q.result.paginate(page: params[:page])
	   respond_to do |format|
		  format.html
		  format.js
	   end
	 end
  end

  def show
    #without pagination and includes is before and with is after
    @question = Question.find(params[:id])
    @articles = @question.articles.includes(comments:[:user]).paginate(page: params[:page], per_page: 1)
	 fresh_when([@question,@articles])
  end

  def new
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = current_user.questions.build(question_params)
	 
	 if @question.save
		flash[:suceess] = "New question posted"
	 else
	 	flash[:error] = "Unexpected Error!"
    end
	 redirect_to(user_path(current_user))
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
	 redirect_to root_url
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:title, :content)
    end

	 def correct_user
		@question = current_user.questions.find_by(id: params[:id])
		redirect_to root_url if @question.nil?
	 end

	 def admin_user
	 	redirect_to(root_path) unless current_user.admin?
	 end

end
