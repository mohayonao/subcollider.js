(function(sc) {
  "use strict";

  /**
   * Returns a new Array whose elements are repeated sequences of the receiver, up to size length. The receiver is unchanged.
   * @arguments _(size)_
   * @example
   *  [ 1, 2, 3 ].wrapExtend(9); // => [ 1, 2, 3, 1, 2, 3, 1, 2, 3 ]
   */
  sc.register("wrapExtend", {
    Array: function(size) {
      size = Math.max(0, size|0);
      var a = new Array(size);
      for (var i = 0; i < size; ++i) {
        a[i] = this[i % this.length];
      }
      return a;
    }
  });

})(sc);
