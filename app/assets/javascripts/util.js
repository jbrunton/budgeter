function coerceData(data) {
  for (var i = 0; i < data.length; ++i) {
    for (var j = 0; j < data[i].length; ++j) {
      var val = data[i][j];
      if (typeof val === 'string') {
        if (val.startsWith('Date(') && val.endsWith(')')) {
          data[i][j] = new Date(val.slice(6,val.length-2));
        }
      }
    }
  }
  return data;
}