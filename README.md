# Weather today

A simple weather app written in [Elm](https://elm-lang.org).

The website files are located under the `public` directory, except for the `main.js` file that should be compiled. Some static data can be customized in the `static.js` file, which is eagerly checked when loading the app.

# Development setup and usage

The development dependencies are managed with [npm](https://www.npmjs.com):

```sh
# Install the development dependencies
npm i 

# Compile an unoptimized main.js with time-travelling debugger
npm run build-dev 

# Compile an optimized main.js
npm run build 

# Just check that it compiles
npm run build-check

# Run the tests
npm run test

# Start a development server with hot reloading and debugger
npm run server-dev

# Start a server with the optimized version
npm run server

# Format the Elm code
npm run format

# Check if some Elm file should be formatted
npm run format-check

# Check if the website static data is valid
npm run static-data-check

# Run all checks: build, format, static data and test
npm run every-check
```

## TODO

* Responsive design.
* Host a demo.
