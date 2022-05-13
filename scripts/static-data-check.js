const { readFileSync } = require('fs');

((warn, load) => {
  console.warn = () => undefined;
  load('./public-dev/main.js');
  load('./public-dev/static.js');
  console.warn = warn;
})(
  console.warn,
  file =>
    eval.call(
      global,
      readFileSync(
        file,
        { encoding: 'utf8' }
      )
    )
);

try {
  Elm.Main.init({
    flags: staticData
  });
} catch (e) {
  if (e.name === 'Error') {
    console.error(e.message);
    process.exit(1);
  }
}
