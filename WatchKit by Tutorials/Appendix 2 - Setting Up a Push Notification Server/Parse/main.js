var express = require('express');
var _ = require('underscore');
var recipesJSONURL = 'https://raw.githubusercontent.com/raywenderlich/recipes/master/Recipes.json';

// Subclass a parse object to be a Recipe object
var Recipe = Parse.Object.extend("Recipe");

// ****************** Prevent Duplicates ******************
Parse.Cloud.beforeSave("Recipe", function(request, response) {
  if (!request.object.get("name")) {
    // 1
    response.error('A Recipe must have a name.');
    return;
  }
  if (!request.object.isNew()) {
    // 2
    response.success();
    return;
  }
  // 3
  var query = new Parse.Query(Recipe);
  query.equalTo("name", request.object.get("name"));

  // 4
  query.first({
    success: function(object) {
      if (object) {
        // 5
        response.error("A Recipe with this name already exists.");
      } else {
        // 6
        response.success();
      }
    },
    error: function(error) {
      response.error("Could not validate uniqueness of this Recipe object.");
    }
  });
});

// ****** Send Push on New Recipe Creation ******
Parse.Cloud.afterSave("Recipe", function(request) {
  // 1
  var recipeName = request.object.get("name");
  var imageURL = request.object.get("imageURL");
	var message = "New '"+recipeName+"' recipe is now available.";

  // 2
  Parse.Push.send({
  // 3
    where: new Parse.Query(Parse.Installation),
    // 4
    data: {
      alert: message,
      category: "new_recipe",
      title: recipeName,
			message: message,
      recipe: {
        name: recipeName,
        imageURL: imageURL
      }
    }
  }, {
    // 5
    success: function() {
      console.log("Push Sent\n");
    },
    error: function(error) { console.error("Push Error "+error.code+" : "+error.message);
    }
  });
});

// ****************** Web Hook ******************
var app = express();

// Global app configuration section
app.use(express.bodyParser()); // Populate req.body

app.post('/new_recipes_notify', function(req, res) {
  // Get Recipes from GitHub Repo
  Parse.Cloud.httpRequest({
    url: recipesJSONURL,
    headers: {
      'Content-Type': 'application/json;charset=utf-8'
    },
    success: function(httpResponse) {
      handleJSON(res, httpResponse);
    },
    error: function(httpResponse) {
      // Something bad happened with the request
      res.status(500);
      res.send("Error\n");
    }
  });
});

function handleJSON(res, httpResponse) {
  // 1
  var fileJSON = JSON.parse(httpResponse.text);
  if (fileJSON.length <= 0) {
    // No records were available for parsing
    res.status(500);
    res.send("Error\n");
    return;
  }
  // 2
  _.each(fileJSON, function(itemJSON) {
    // 3
    var recipe = new Recipe();
               
    // 4
    recipe.save(itemJSON, {
      success: function(savedRecipe) {
      },
      error: function(savedRecipe, error) {
				console.log(error)
      }
    });
  });
  // 5. Everything worked out
  res.send("Success\n");
}

// Begin listening for calls to the web hook
app.listen();

