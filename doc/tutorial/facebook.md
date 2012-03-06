# How to build a Facebook application within Rails 3 using the rest-more gem

1. Before you start, I strongly recommend reading these:

    * Apps on Facebook.com -> <http://developers.facebook.com/docs/guides/canvas/>
    * Graph API -> <http://developers.facebook.com/docs/reference/api/>
    * Authentication -> <http://developers.facebook.com/docs/authentication/>
    * Heroku: Building a Facebook Application -> <http://devcenter.heroku.com/articles/facebook/>


2. Go to [FB Developers website](http://facebook.com/developers) and create a new FB app. Set its canvas name, canvas url and your site URL. Make sure the canvas type is set to "iframe" (which should be the case by default).


3. Build a new Rails application.

        rails new <name>


4. Declare rest-more and its dependencies in the Gemfile. Add these lines:

        gem 'rest-more'

        # these gems are used in rest-more
        gem 'json'        # you may also use other JSON parsers/generators, i.e. 'yajl-ruby' or 'json_pure'

   And run:

        bundle install


5. In order to configure your Rails application for the Facebook application you created, you must create a `rest-core.yaml` file in your /config directory and fill it with your Facebook configuration. If you plan to run your application in the Facebook canvas, also provide a canvas name.

	Example:

        development:
          facebook:
            app_id: 'XXXXXXXXXXXXXX'
            secret: 'YYYYYYYYYYYYYYYYYYYYYYYYYYY'
            callback_host: 'my.dev.host.com'

        production:
          facebook:
            app_id: 'XXXXXXXXXXXXXX'
            secret: 'YYYYYYYYYYYYYYYYYYYYYYYYYYY'
            canvas: 'yourcanvasname'
            callback_host: 'my.production.host.com'


    If you push to Heroku, your production callback_host should be `yourappname.heroku.com`. You can also access your app directly running `rails server` (or just `rails s`) in your console, but if you do not have an external IP address (e.g. you are behind a NAT), you will need to use a service called a tunnel in order to make your application accessible to the outer world (and Facebook callbacks). You'll find more information on setting up a tunnel here: <http://tunnlr.com/>.

6. Let's create a first controller for your app - ScratchController.

        rails generate controller Scratch

7. The next step will be to include rest-more in your controller. You should put this line in:

        include RC::Facebook::RailsUtil

     Now you can make use of the rest-more commands :)

8. To actually use rest-more in a controller action, you will need to first call "rc_facebook_setup", which reads the configuration from the rest-core.yaml and creates a Facebook client.   Let's set this up in a before_filter.

    Add this line after the `include RestGraph::RailsUtil`:

        before_filter :filter_setup_facebook

    And declare filter_setup_facebook as a private function:

        private
        def filter_setup_facebook
          rc_facebook_setup(:auto_authorize => true)
        end

    The `:auto_authorize` argument of `rc_facebook_setup` tells rest-more to redirect users to the app authorization page if the app is not authorized yet.

    Hooray! You can now perform all kinds of Graph API operations using the Facebook client.

9. Let's start with following sample action in the Scratch controller:

        def me
          render :text => rc_facebook.get('me').inspect
        end

10. To run this, go to the /config/routes.rb file to set up the default routing. For now you will just need this line:

        match ':controller/:action'

11. Commit your change in git, and then push to Heroku:

        git add .
        git commit -m "first test of rest-more using scratch/me"
        git push heroku master

    After you push your app to Heroku, you can open <http://yourappname.heroku.com/scratch/me> in your browser. If you are not yet logged into Facebook, it will ask you to log in.  If you are logged in your Facebook account, this address should redirect you to the authorization page and ask if you want to let your application access your public information. After you confirm, you should be redirected back to 'scratch/me' action which will show your basic information.

12. To see other information, such as your home feed, is very easy. You can add another sample action to your controller:

        def feed
          render :text => rc_facebook.get('me/home').inspect
        end

    If you will push the changes to Heroku and go to <http://yourappname.heroku.com/scratch/feed>, the page should display a JSON hash with all the data from your Facebook home feed.


13. Now let's try to access your Facebook wall. You need to add a new action to your controller:

        def wall
          render :text => rc_facebook.get('me/feed').inspect
        end

    Note that Facebook's naming is such that your home news feeds is accessed via `me/home` and your profile walls is accessed via `me/feed` ...

    Actually, I need to warn you that this time the action won't work properly. Why? Because users didn't grant you the permission to access their walls! You need to ask them for this special permission and that means you need to add something more to your controller.

    So, we will organize all the permissions we need as a scope and pass them to the `rc_facebook_setup` call. I find it handy to make the scope array and declare what kind of permissions I need just inside this array. If you feel it's a good idea, you can add this line to your private setup function, just before you call `rc_facebook_setup`:

        scope = []
        scope << 'read_stream'

    The only permission you need right now is the 'read_stream' permission. You can find out more about different kinds of user permissions here: <http://developers.facebook.com/docs/authentication/permissions/>

    You also need to add the `auto_authorize_scope` argument to the `rc_facebook_setup`. It will look this way now:

        rc_facebook_setup(:auto_authorize => true, :auto_authorize_scope => scope.join(','))

    As you see, you might as well pass the argument like this `:auto_authorize_scope => 'read_stream'`, but once you have to get a lot of different permissions, it's very useful to put them all in an array, because it's more readable and you can easily delete or comment out any one of them.

    Now save your work and push it to Heroku or just try in your tunneled development environment. /scratch/wall URL should give you the hash with user's wall data now!

    Remember. Anytime you need to get data of a new kind, you need to ask user for a certain permission first and that means you need to declare this permission in your scope array!

14. What else? If you know how to deal with hashes then you will definitely know how to get any kind of data you want using the rest_graph object. Let's say you want to get a last object from a user's wall (last in terms of time, last posted, so the first on the wall and therefore first to Ruby). Let's take a look at the /scratch/feed page. The hash which is printed on this page has 2 keys - data and paging. Let's leave the paging key aside. What's more interesting here comes as a value of 'data'. So the last object in any user's wall will be simply:

        rc_facebook.get('me/feed')['data'].first

    Now let's say you want only to keep the name of the author of this particular object. You can get it by using:

        rc_facebook.get('me/feed')['data'].first['from']['name']

    That's it!

15. More information on customizing rest-more and its functions are to be found here: <https://github.com/cardinalblue/rest-more>
