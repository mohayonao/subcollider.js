(function(sc) {
  "use strict";

  sc.register("hanWindow", {
    Number: function() {
      if (this < 0 || this > 1) { return 0; }
      return 0.5 - 0.5 * Math.cos(this * 2 * Math.PI);
    },
    Array: function() {
      return this.map(function(x) { return x.hanWindow(); });
    }
  });

})(sc);
