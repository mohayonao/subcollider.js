(function(sc) {
  "use strict";

  sc.register("atDec", {
    Array: function(index, dec) {
      dec = dec === void 0 ? 1 : dec;
      return this.put(index, this.at(index).opSub(dec));
    }
  });

})(sc);
