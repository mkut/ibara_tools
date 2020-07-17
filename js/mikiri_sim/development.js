import path from 'path'

const src  = path.resolve(__dirname, 'src')
const dist  = path.resolve(__dirname)

export default {
  mode: 'development',
  entry: src + '/index.jsx',

  output: {
    path: dist,
    filename: 'bundle.js'
  },

  module: {
    rules: [
      {
        test: /\.jsx$/,
        exclude: /node_modules/,
        loader: 'babel-loader'
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ]
  },

  resolve: {
    extensions: ['.js', '.jsx']
  },

  plugins: []
}