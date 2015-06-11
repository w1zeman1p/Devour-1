Devour.Routers.MainRouter = Backbone.Router.extend({

  initialize: function(options) {
    this.$rootEl = options.$rootEl;
    this.decks = options.collection;
  },

  routes: {
    '':'index',
    'decks/new':'newDeck',
    'decks/:id/edit':'editDeck',
    'decks/:id':'showDeck'
  },

  index: function() {
    this.decks.fetch({
      success: function() {
        console.log(this.decks);
      }
    });
    var indexView = new Devour.Views.DecksIndex({ collection: this.decks });
    this.swapView(indexView);
  },

  newDeck: function() {
    var deck = new Devour.Models.Deck();
    var newView = new Devour.Views.DeckForm({
      model: deck,
      collection: this.decks,
    });
    this.swapView(newView);
  },

  edit: function(id) {
    var deck = this.decks.getOrFetch(id);
    var editView = new Devour.Views.DeckForm({
      model: deck,
      collection: this.decks,
    });
    this.swapView(editView);
  },

  showDeck: function(id) {
    var deck = this.decks.getOrFetch(id);
    var showView = new Devour.Views.DeckShow({ model: deck });
    this.swapView(showView);
  },

  swapView: function(view) {
    this._currentView && this._currentView.remove();
    this._currentView = view;
    this.$rootEl.html(view.$el);
    view.render();
  }

});
