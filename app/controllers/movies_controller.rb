class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]
  before_action :check_movie, only: [:create]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
      )
  end

  def create
    movie = Movie.new(movie_params)

    if @movie.nil?
      if movie.save
        render json: movie.as_json(only: [:id]), status: :created
        return
      else
        render json: {
            errors: movie.errors.messages
          }, status: :bad_request
        return
      end
    else
      render json: {
          errors: "Can't add a movie twice."
          }, status: :bad_request
      return
    end
  end

  private
  def movie_params
    return params.permit(:title, :release_date, :overview, :image_url, :external_id)
  end

  def check_movie
    @movie = Movie.find_by(external_id: params[:external_id])
  end

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
