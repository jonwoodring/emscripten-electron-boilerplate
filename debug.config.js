var webpack = require("webpack")

module.exports = [
{
  name: "renderer",
  entry: { rndr: './d-obj/rndr.js'},
  devtool: "source-map",
  output: {
    path: './debug/',
    filename: '[name].js'
  },
  module: {
    loaders: [
      {
        test: /\.js$/,
        loader: "shebang-loader!babel-loader!octal-number-loader",
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
  entry: { main: './d-obj/main.js'},
  devtool: "source-map",
  output: {
    path: './debug/',
    filename: '[name].js'
  },
  module: {
    loaders: [
      {
        test: /\.js$/,
        loader: "shebang-loader!babel-loader!octal-number-loader",
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
