// module.exports = {
//     rules: [
//       {
//         test: /\.(glsl|vs|fs|vert|frag)$/,
//         exclude: /node_modules/,
//         use: [
//           'raw-loader',
//           'glslify-loader'
//         ]
//       }
//     ]
//   }

module.exports = {
    chainWebpack: config => {
      // GraphQL Loader
      config.module
        .rule('glsl')
        .test(/\.(glsl|vs|fs|vert|frag)$/)
        .use('raw-loader')
          .loader('raw-loader')
          .end()
        // Add another loader
        .use('glslify-loader')
          .loader('glslify-loader')
          .end()
    }
  }