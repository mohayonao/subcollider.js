(function(sc) {
  "use strict";

  sc.register("gaussCurve", {
    Number: function(a, b, c) {
      a = a === void 0 ? 1 : a;
      b = b === void 0 ? 0 : b;
      c = c === void 0 ? 1 : c;
      var x = this - b;
      return a * (Math.exp((x * x) / (-2.0 * (c * c))));
    },
    Array: function(a, b, c) {
      return this.map(function(x) { return x.gaussCurve(a, b, c); });
    }
  });

})(sc);
