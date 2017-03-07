module CategoryApi
  class Categories < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header
    #
    helpers do
    end

    resource :categories do
      # => /api/v1/categories/
      desc 'Get all categories'
      get '/all' do
        Category.all
      end

      desc 'Get default categories'
      get '/default' do
        Category.where(default: true)
      end

      desc 'Get a category by id'
      params do
        requires :id, type: String, desc: 'Category ID'
      end
      get ':id' do
        Category.where(id: params[:id]).first!
      end

      desc 'create new category'
      params do
        requires :category, type: Hash do
          requires :name, type: String, desc: 'Category name'
          requires :default, type: Boolean, desc: 'Default'
        end
      end
      post '/new' do
        category_params = params['category']
        category = Category.create!(
          name: category_params['name'],
          default: category_params['default']
        )
        category
      end

      desc 'Delete a category'
      params do
        requires :id, type: String, desc: 'Category ID'
      end
      delete ':id' do
        category = Category.find(params[:id])
        category.destroy
      end
    end
  end
end
