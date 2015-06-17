var RepositoriesView = Backbone.View.extend({

  initialize: function () {
    this.render();
  },

  repositoryTemplate: _.template("<div class='open-source-category-header'>" +
                                  "<div class='open-source-category-header-title'>" +
                                    "<span><b>Title</b></span>" +
                                  "</div>" +
                                  "<div class='open-source-category-header-description'>" +
                                    "<span><b>Description</b></span>" +
                                  "</div>" +
                                  "<div class='open-source-category-header-updated'>" +
                                    "<span><b>Created</b></span>" +
                                  "</div>" +
                                  "<footer>" +
                                  "</footer>" +
                                 "</div>" +
                                  "<% _.each(collection, function(model) { %>" +
                                    "<div class='open-source-project <%= model.category %>'>" +
                                      "<% if (model.image !== 'undefined') { %>" +
                                        "<div class = 'open-source-featured-image'>" +
                                          "<img src='<%= model.image %>'>" +
                                        "</div>" +
                                      "<% } %>" +
                                      "<div class='open-source-title'>" +
                                        "<h2><a href='<%= model.repository %>'><%= model.title %></a></h2>" +
                                      "</div>" +
                                      "<div class='open-source-description'>" +
                                        "<%= model.description %>" +
                                        "<div class='open-source-description-link'>" +
                                        "<a href='<%= model.repository %>'><%= model.link %></a>" +
                                        "</div>" +
                                      "</div>" +
                                      "<div class='open-source-updated'>" +
                                        "<span><%= model.created %></span>" +
                                      "</div>" +
                                      "<footer>" +
                                      "</footer>" +
                                    "</div>" +
                                  "<% }); %>"),

  render: function() {
    this.$el.html( this.repositoryTemplate({ collection: this.collection.toJSON() }));
    return this;
  },

});

