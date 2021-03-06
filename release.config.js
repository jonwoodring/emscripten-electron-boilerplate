var webpack = require("webpack")

module.exports = [
{
  name: "renderer",
  entry: { rndr: './r-js/rndr.js'},
  output: {
    path: './release/',
    filename: '[name].js'
  },
  plugins: [ new webpack.optimize.UglifyJsPlugin(),
             new webpack.optimize.OccurrenceOrderPlugin(true) ],
  module: {
    loaders: [
      {
        test: /\.js$/,
        loader: "babel-loader",
        exclude: /.\/r-js/
      },
      {
        test: /\.css$/,
        loader: "style-loader!css-loader"
      },
      {
        test: /\.(svg|eot|woff|woff2|png|jpg|ttf)$/,
        loader: "url-loader"
      },
      {
        test: /\.json$/,
        loader: "json-loader"
      }
    ]
  },
  resolve: {
    extensions: ['.js']
  },
  target: "electron-renderer"
},
{
  name: "main",
  entry: { main: './r-js/main.js'},
  output: {
    path: './release/',
    filename: '[name].js'
  },
  plugins: [ new webpack.optimize.UglifyJsPlugin(),
             new webpack.optimize.OccurrenceOrderPlugin(true)],
  module: {
    loaders: [
      {
        test: /\.js$/,
        loader: "babel-loader",
        exclude: /.\/r-js/
      },
      {
        test: /\.css$/,
        loader: "style-loader!css-loader"
      },
      {
        test: /\.(svg|eot|woff|woff2|png|jpg|ttf)$/,
        loader: "url-loader"
      },
      {
        test: /\.json$/,
        loader: "json-loader"
      }
    ]
  },
  resolve: {
    extensions: ['.js']
  },
  target: "electron-main",
  node: {
    __dirname: false,
    __filename: false
  }
}
]
