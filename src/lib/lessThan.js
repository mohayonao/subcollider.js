(function(sc) {
  "use strict";

  sc.register(["lessThan", "<="], {
    Number: function(num) {
      if (Array.isArray(num)) {
        return num.map(function(num) { return this.lessThan(num); }, this);
      }
      return this <= num;
    },
    Array: function(num) {
      if (Array.isArray(num)) {
        return this.map(function(x, i) { return x.lessThan(num.wrapAt(i)); });
      } else {
        return this.map(function(x) { return x.lessThan(num); });
      }
    }
  });

})(sc);
